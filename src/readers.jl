pushopt(options::Dict,expr::Expr) = Base.Meta.isexpr(expr,:(=)) && (options[expr.args[1]] = expr.args[2])

type MarkupInput
    codestart::Regex
    codeend::Regex
end

type ScriptInput
  doc_line::Regex
  doc_start::Regex
  opt_line::Regex
  opt_start::Regex
end

const input_formats = Dict{AbstractString, Any}(
        "noweb" => MarkupInput(r"^<<(.*?)>>=\s*$",
                    r"^@\s*$"),
        "markdown" => MarkupInput(
                      r"^[`~]{3,}(?:\{|\{\.|)julia(?:;|)\s*(.*?)(\}|\s*)$",
                      r"^[`~]{3,}\s*$"),
        "script" => ScriptInput(
          r"(^#'.*)|(^#%%.*)|(^# %%.*)",
          r"(^#')|(^#%%)|(^# %%)",
          r"(^#\+.*$)|(^#%%\+.*$)|(^# %%\+.*$)",
          r"(^#\+)|(^#%%\+)|(^# %%\+)")
        )

"""Detect the input format based on file extension"""
function detect_informat(source::AbstractString)
  ext = lowercase(splitext(source)[2])

  ext == ".jl" && return "script"
  ext == ".jmd" && return "markdown"
  return "noweb"
end



"""Read and parse input document"""
function read_doc(source::AbstractString, format=:auto)
    format == :auto && (format = detect_informat(source))
    document = @compat readstring(source)
    parsed = parse_doc(document, format)
    doc = WeaveDoc(source, parsed)
end

function parse_doc(document::AbstractString, format="noweb"::AbstractString)
  return parse_doc(document, input_formats[format])
end

"""Parse documents with Weave.jl markup"""
function parse_doc(document::AbstractString, format::MarkupInput)
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
      #@show optionAbstractString
      options = Dict{Symbol,Any}()
      if length(optionString) > 0
          expr = parse(optionString)
          Base.Meta.isexpr(expr,:(=)) && (options[expr.args[1]] = expr.args[2])
          Base.Meta.isexpr(expr,:toplevel) && map(pushopt,fill(options,length(expr.args)),expr.args)
      end
      haskey(options, :label) && (options[:name] = options[:label])
      haskey(options, :name) || (options[:name] = nothing)
      #options = merge(rcParams[:chunk_defaults], options)
      #@show options
      chunk = DocChunk(content, docno, start_line)
      #chunk = @compat Dict{Symbol,Any}(:type => "doc", :content => content,
      #                                 :number => docno,:start_line => start_line)
      docno += 1
      start_line = lineno
      push!(parsed, chunk)
      content = ""
      continue
    end
    if ismatch(codeend, line) && state=="code"

      chunk = CodeChunk(content, codeno, start_line, optionString, options)
      #chunk = @compat Dict{Symbol,Any}(:type => "code", :content => content,
#                                   :number => codeno, :options => options,
#                                       :optionAbstractString => optionAbstractString,
#                                       :start_line => start_line)

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
    chunk = DocChunk(content, docno, start_line)
    #chunk = @compat Dict{Symbol,Any}(:type => "doc", :content => content,
    #                                 :number =>  docno, :start_line => start_line)
    push!(parsed, chunk)
  end
  return parsed
end

"""Parse .jl scripts with Weave.jl markup"""
function parse_doc(document::AbstractString, format::ScriptInput)
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
          line = replace(line, doc_start, "", 1)
      if startswith(line, " ")
          line = replace(line, " ", "", 1)
      end
      if state == "code"  && strip(read) != ""
          chunk = CodeChunk("\n" * rstrip(read), codeno, start_line, optionString, options)
          push!(parsed, chunk)
          codeno +=1
          read = ""
          start_line = lineno
      end
      state = "doc"
    elseif (m = match(opt_line, line)) != nothing
      start_line = lineno
      if state == "code" && strip(read) !=""
          chunk = CodeChunk("\n" * rstrip(read), codeno, start_line, optionString, options)
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

      optionString = replace(line, opt_start, "", 1)
      #Get options
      options = Dict{Symbol,Any}()
      if length(optionString) > 0
          expr = parse(optionString)
          Base.Meta.isexpr(expr,:(=)) && (options[expr.args[1]] = expr.args[2])
          Base.Meta.isexpr(expr,:toplevel) && map(pushopt,fill(options,length(expr.args)),expr.args)
      end
      haskey(options, :label) && (options[:name] = options[:label])
      haskey(options, :name) || (options[:name] = nothing)

      state = "code"
      continue
    elseif state == "doc" && strip(line) != "" && strip(read) != ""
      state = "code"
      (docno > 1) && (read = "\n" * read) # Add whitespace to doc chunk. Needed for markdown output
      chunk = DocChunk(read, docno, start_line)
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
    chunk = CodeChunk("\n" * rstrip(read), codeno, start_line, optionString, options)
    push!(parsed, chunk)
  else
    chunk = DocChunk(read, docno, start_line)
    push!(parsed, chunk)
  end

  return parsed
end
