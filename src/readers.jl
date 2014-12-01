function read_noweb(document)
  doctext = readall(open(document))
  #doctext = document #Replace with file...
  codestart = r"^<<(.*?)>>="
  codeend = r"^@(\s*)$"
  state = "doc"

  docno = 1
  codeno = 1
  content = ""
  lineno = 0
  start_line = 0

  options = Dict()
  optionstring = ""
  parsed = Dict[]
  for (lineno, line) in enumerate(split(doctext, "\n"))

    if ismatch(codestart, line) && state=="doc"
      state = "code"
      m = match(codestart, line)
      optionstring=m.captures[1]
      #println(m.captures[1])
      if strip(optionstring)==""
        options = Dict()
      else
          try
              options = eval(parse("{" * optionstring * "}"))
          catch
              options = Dict()
              warn(string("Invalid format for chunk options line: ", lineno))
          end
      end
      haskey(options, "label") && (options["name"] = options["label"])
      haskey(options, "name") || (options["name"] = nothing)

      chunk = {"type" => "doc", "content"=> content, "number" =>  docno, "start_line"=>start_line}
      docno += 1
      start_line = lineno
      push!(parsed, chunk)
      content = ""
      continue
    end
    if ismatch(codeend, line) && state=="code"
      chunk = {"type" => "code", "content" => content, "number" => codeno,
      "options"=>options,"optionstring"=>optionstring, "start_line"=>start_line}
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
    chunk = {"type" => "doc", "content"=> content, "number" =>  docno, "start_line"=>lineno}
    push!(parsed, chunk)
  end

  return parsed
end
