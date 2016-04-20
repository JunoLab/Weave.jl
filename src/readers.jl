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


"""Read and parse input document"""
function read_doc(source::AbstractString, format="noweb"::AbstractString)
    document = @compat readstring(source)
    parsed = parse_doc(document, format)
    doc = WeaveDoc(source, parsed)
end

"""Parse chunks from AbstractString"""
function parse_doc(document::AbstractString, format="noweb"::AbstractString)
  lines = split(document, "\n")

  codestart = input_formats[format][:codestart]
  codeend = input_formats[format][:codeend]
  state = "doc"

  docno = 1
  codeno = 1
  content = ""
  start_line = 0

  options = Dict()
  optionAbstractString = ""
  parsed = Any[]
  for lineno in 1:length(lines)
    line = lines[lineno]
    if (m = match(codestart, line)) != nothing && state=="doc"
      state = "code"
      if m.captures[1] == nothing
          optionAbstractString = ""
      else
          optionAbstractString=strip(m.captures[1])
      end
      #@show optionAbstractString
      options = Dict{Symbol,Any}()
      if length(optionAbstractString) > 0
          expr = parse(optionAbstractString)
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

      chunk = CodeChunk(content, codeno, start_line, optionAbstractString, options)
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
