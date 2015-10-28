pushopt(options::Dict,expr::Expr) = Base.Meta.isexpr(expr,:(=)) && (options[expr.args[1]] = expr.args[2])


const input_formats = @compat Dict{AbstractString, Any}(
        "noweb" => Dict{Symbol, Any}(
                    :codestart => r"^<<(.*?)>>=\s*$",
                    :codeend => r"^@\s*$"
                    ),
        "markdown" => Dict{Symbol, Any}(
                    :codestart => r"(?:^(?:`|~){3,}\s*(?:\{|\{\.|)julia(?:;|\s)(.*)\}\s*$)|(?:^(?:`|~){3,}\s*julia\s*$)",
                    :codeend => r"^`|~{3,}\s*$"
                    )
        )


@doc "Read and parse input document" ->
function read_doc(source::AbstractString, format="noweb"::AbstractString)
    document = bytestring(open(source) do io
        # mmap_array(UInt8,(filesize(source),),io)
        Mmap.mmap(io,Vector{UInt8},(filesize(source),))
    end)
    parsed = parse_doc(document, format)
    doc = WeaveDoc(source, parsed)
end

@doc "Parse chunks from string" ->
function parse_doc(document::AbstractString, format="noweb"::AbstractString)
  #doctext = readall(open(document))
  lines = split(document, "\n")

  codestart = input_formats[format][:codestart]
  codeend = input_formats[format][:codeend]
  state = "doc"

  docno = 1
  codeno = 1
  content = ""
  start_line = 0

  options = Dict()
  optionstring = ""
  parsed = Any[]
  for lineno in 1:length(lines)
    line = lines[lineno]
    if (m = match(codestart, line)) != nothing && state=="doc"
      state = "code"
      if m.captures[1] == nothing
          optionstring = ""
      else
          optionstring=strip(m.captures[1])
      end
      #@show optionstring
      options = Dict{Symbol,Any}()
      if length(optionstring) > 0
          expr = parse(optionstring)
          Base.Meta.isexpr(expr,:(=)) && (options[expr.args[1]] = expr.args[2])
          Base.Meta.isexpr(expr,:toplevel) && map(pushopt,fill(options,length(expr.args)),expr.args)
      end
      haskey(options, :label) && (options[:name] = options[:label])
      haskey(options, :name) || (options[:name] = nothing)
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

      chunk = CodeChunk(content, codeno, start_line, optionstring, options)
      #chunk = @compat Dict{Symbol,Any}(:type => "code", :content => content,
#                                   :number => codeno, :options => options,
#                                       :optionstring => optionstring,
#                                       :start_line => start_line)

      codeno+=1
      start_line = lineno
      content = ""
      state = "doc"
      push!(parsed, chunk)
      continue
    end

    content *= "\n" * line
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
