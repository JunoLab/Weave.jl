import JSON, YAML

pushopt(options::Dict,expr::Expr) = Base.Meta.isexpr(expr,:(=)) && (options[expr.args[1]] = expr.args[2])

mutable struct MarkupInput
    codestart::Regex
    codeend::Regex
    inline::Regex
end

mutable struct ScriptInput
  doc_line::Regex
  doc_start::Regex
  opt_line::Regex
  opt_start::Regex
  inline::Regex
end

mutable struct NotebookInput
  inline
end

const input_formats = Dict{AbstractString, Any}(
        "noweb" => MarkupInput(r"^<<(.*?)>>=\s*$",
                    r"^@\s*$",
                    r"`j\s+(.*?)`|^!\s(.*)$"m
                    ),
        "markdown" => MarkupInput(
                      r"^[`~]{3,}(?:\{|\{\.|)julia(?:;|)\s*(.*?)(\}|\s*)$",
                      r"^[`~]{3,}\s*$",
                      r"`j\s+(.*?)`|^!\s(.*)$"m),
        "script" => ScriptInput(
          r"(^#'.*)|(^#%%.*)|(^# %%.*)",
          r"(^#')|(^#%%)|(^# %%)",
          r"(^#\+.*$)|(^#%%\+.*$)|(^# %%\+.*$)",
          r"(^#\+)|(^#%%\+)|(^# %%\+)",
          r"`j\s+(.*?)`|^!\s(.*)$"m),
        "notebook" => NotebookInput(nothing) #Don't parse inline code from notebooks
        )

"""Detect the input format based on file extension"""
function detect_informat(source::AbstractString)
  ext = lowercase(splitext(source)[2])

  ext == ".jl" && return "script"
  ext == ".jmd" && return "markdown"
  ext == ".ipynb" && return "notebook"
  return "noweb"
end

"""Read and parse input document"""
function read_doc(source::AbstractString, format=:auto)
    format == :auto && (format = detect_informat(source))
    document = read(source, String)
    document = replace(document, "\r\n" => "\n")
    parsed = parse_doc(document, format)
    header = parse_header(parsed[1])
    doc = WeaveDoc(source, parsed, header)
    haskey(header, "options") && header_chunk_defaults!(doc)
    return doc
end

function parse_header(chunk::CodeChunk)
  return Dict()
end

function parse_header(chunk::DocChunk)
  m = match(r"^---$(?<header>.+)^---$"ms, chunk.content[1].content)
  if m !== nothing
    header = YAML.load(string(m[:header]))
  else
    header = Dict()
  end
  return header
end

function parse_doc(document::AbstractString, format="noweb"::AbstractString)
  return parse_doc(document, input_formats[format])
end

"""Parse documents with Weave.jl markup"""
function parse_doc(document::AbstractString, format::MarkupInput)
  document = replace(document, "\r\n" => "\n")
  lines = split(document, "\n")

  codestart = format.codestart
  codeend = format.codeend
  state = "doc"

  docno = 1
  codeno = 1
  content = ""
  start_line = 0

  options = Dict()
  optionString = ""
  parsed = Any[]
  for lineno in 1:length(lines)
    line = lines[lineno]
    if (m = match(codestart, line)) != nothing && state=="doc"
      state = "code"
      if m.captures[1] == nothing
          optionString = ""
      else
          optionString=strip(m.captures[1])
      end

      options = Dict{Symbol,Any}()
      if length(optionString) > 0
          expr = Meta.parse(optionString)
          Base.Meta.isexpr(expr,:(=)) && (options[expr.args[1]] = expr.args[2])
          Base.Meta.isexpr(expr,:toplevel) && map(pushopt,fill(options,length(expr.args)),expr.args)
      end
      haskey(options, :label) && (options[:name] = options[:label])
      haskey(options, :name) || (options[:name] = nothing)

      if !isempty(strip(content))
        chunk = DocChunk(content, docno, start_line, format.inline)
        docno += 1
        push!(parsed, chunk)
      end

      content  = ""
      start_line = lineno

      continue

    end
    if occursin(codeend, line) && state=="code"

      chunk = CodeChunk(content, codeno, start_line, optionString, options)

      codeno+=1
      start_line = lineno
      content = ""
      state = "doc"
      push!(parsed, chunk)
      continue
    end

    if lineno == 1
       content *= line
    else
      content *= "\n" * line
    end
  end

  #Remember the last chunk
  if strip(content) != ""
    chunk = DocChunk(content, docno, start_line, format.inline)
    #chunk =  Dict{Symbol,Any}(:type => "doc", :content => content,
    #                                 :number =>  docno, :start_line => start_line)
    push!(parsed, chunk)
  end
  return parsed
end

"""Parse .jl scripts with Weave.jl markup"""
function parse_doc(document::AbstractString, format::ScriptInput)
  document = replace(document, "\r\n" => "\n")
  lines = split(document, "\n")

  doc_line = format.doc_line
  doc_start = format.doc_start
  opt_line = format.opt_line
  opt_start = format.opt_start

  read = ""
  chunks = []
  docno = 1
  codeno = 1
  content = ""
  start_line = 1
  options = Dict{Symbol,Any}()
  optionString = ""
  parsed = Any[]
  state = "code"
  lineno = 1
  n_emptylines = 0



  for lineno in 1:length(lines)
    line = lines[lineno]
    if (m = match(doc_line, line)) != nothing && (m = match(opt_line, line)) == nothing
          line = replace(line, doc_start => "", count=1)
      if startswith(line, " ")
          line = replace(line, " " => "", count=1)
      end
      if state == "code"  && strip(read) != ""
          chunk = CodeChunk("\n" * strip(read), codeno, start_line, optionString, options)
          push!(parsed, chunk)
          codeno +=1
          read = ""
          start_line = lineno
      end
      state = "doc"
    elseif (m = match(opt_line, line)) != nothing
      start_line = lineno
      if state == "code" && strip(read) !=""
          chunk = CodeChunk("\n" * strip(read), codeno, start_line, optionString, options)
          push!(parsed, chunk)
          read = ""
          codeno +=1
      end
      if state == "doc" && strip(read) != ""
          (docno > 1) && (read = "\n" * read) # Add whitespace to doc chunk. Needed for markdown output
          chunk = DocChunk(read, docno, start_line)
          push!(parsed, chunk)
          read = ""
          docno += 1
      end

      optionString = replace(line, opt_start => "", count=1)
      #Get options
      options = Dict{Symbol,Any}()
      if length(optionString) > 0
          expr = Meta.parse(optionString)
          Base.Meta.isexpr(expr,:(=)) && (options[expr.args[1]] = expr.args[2])
          Base.Meta.isexpr(expr,:toplevel) && map(pushopt,fill(options,length(expr.args)),expr.args)
      end
      haskey(options, :label) && (options[:name] = options[:label])
      haskey(options, :name) || (options[:name] = nothing)

      state = "code"
      continue
    elseif state == "doc" #&& strip(line) != "" && strip(read) != ""
      state = "code"
      (docno > 1) && (read = "\n" * read) # Add whitespace to doc chunk. Needed for markdown output
      chunk = DocChunk(read, docno, start_line, format.inline)
      push!(parsed, chunk)
      options = Dict{Symbol,Any}()
      start_line = lineno
      read = ""
      docno += 1
    end
    read *= line * "\n"

    if strip(line) == ""
      n_emptylines += 1
    else
      n_emptylines = 0
    end
  end

  # Handle the last chunk
  if state == "code"
    chunk = CodeChunk("\n" * strip(read), codeno, start_line, optionString, options)
    push!(parsed, chunk)
  else
    chunk = DocChunk(read, docno, start_line, format.inline)
    push!(parsed, chunk)
  end

  return parsed
end

"""Parse IJUlia notebook"""
function parse_doc(document::String, format::NotebookInput)
  document = replace(document, "\r\n" => "\n")
  nb = JSON.parse(document)
  parsed = Any[]
  options = Dict{Symbol,Any}()
  opt_string = ""
  docno = 1
  codeno = 1

  for cell in nb["cells"]
    srctext = "\n" * join(cell["source"], "")

    if cell["cell_type"] == "code"
      chunk = CodeChunk(rstrip(srctext), codeno, 0, opt_string, options)
      push!(parsed, chunk)
      codeno += 1
    else
      chunk = DocChunk(srctext * "\n", docno, 0)
      push!(parsed, chunk)
      docno +=1
    end
  end

return parsed
end

#Use this if regex is undefined
function parse_inline(text, noex)
    return Inline[InlineText(text, 1, length(text), 1)]
end

function parse_inline(text::AbstractString, inline_ex::Regex)
    occursin(inline_ex, text) || return Inline[InlineText(text, 1, length(text), 1)]

    inline_chunks = eachmatch(inline_ex, text)
    s = 1
    e = 1
    res = Inline[]
    textno = 1
    codeno = 1

    for ic in inline_chunks
        s = ic.offset
        doc = InlineText(text[e:(s-1)], e, s-1, textno)
        textno += 1
        push!(res, doc)
        e = s + lastindex(ic.match)
        ic.captures[1] !== nothing && (ctype = :inline)
        ic.captures[2] !== nothing && (ctype = :line)
        cap = filter(x -> x !== nothing, ic.captures)[1]
        push!(res, InlineCode(cap, s, e, codeno, ctype))
        codeno += 1
    end
    push!(res, InlineText(text[e:end], e, length(text), textno))

    return res
end
