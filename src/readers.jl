pushopt(options::Dict,expr::Expr) = Base.Meta.isexpr(expr,:(=)) && (options[expr.args[1]] = expr.args[2])

function read_noweb(document)
  #doctext = readall(open(document))
  lines = split(bytestring(open(document) do io
                             mmap_array(Uint8,(filesize(document),),io)
                           end), "\n")
  #doctext = document #Replace with file...
  codestart = r"^<<(.*?)>>="
  codeend = r"^@(\s*)$"
  state = "doc"

  docno = 1
  codeno = 1
  content = ""
  start_line = 0

  options = Dict()
  optionstring = ""
  parsed = Dict[]
  for lineno in 1:length(lines)
    line = lines[lineno]
    if (m = match(codestart, line)) != nothing && state=="doc"
      state = "code"
      optionstring=strip(m.captures[1])
      @show optionstring
      options = Dict{Symbol,Any}()
      if length(optionstring) > 0
          expr = parse(optionstring)
          Base.Meta.isexpr(expr,:(=)) && (options[expr.args[1]] = expr.args[2])
          Base.Meta.isexpr(expr,:toplevel) && map(pushopt,fill(options,length(expr.args)),expr.args)
      end
      haskey(options, :label) && (options[:name] = options[:label])
      haskey(options, :name) || (options[:name] = nothing)
      @show options
      chunk = @compat Dict{Symbol,Any}(:type => "doc", :content => content,
                                       :number => docno,:start_line => start_line)
      docno += 1
      start_line = lineno
      push!(parsed, chunk)
      content = ""
      continue
    end
    if ismatch(codeend, line) && state=="code"
      chunk = @compat Dict{Symbol,Any}(:type => "code", :content => content,
                                       :number => codeno, :options => options,
                                       :optionstring => optionstring,
                                       :start_line => start_line)
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
  if content != ""
    chunk = @compat Dict{Symbol,Any}(:type => "doc", :content => content,
                                     :number =>  docno, :start_line => start_line)
    push!(parsed, chunk)
  end

  return parsed
end
