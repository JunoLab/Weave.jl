function parse_script(document_body)
    lines = split(document_body, "\n")

    doc_line = r"(^#'.*)|(^#%%.*)|(^# %%.*)"
    doc_start = r"(^#')|(^#%%)|(^# %%)"
    opt_line = r"(^#\+.*$)|(^#%%\+.*$)|(^# %%\+.*$)"
    opt_start = r"(^#\+)|(^#%%\+)|(^# %%\+)"

    read = ""
    docno = 1
    codeno = 1
    content = ""
    start_line = 1
    options = Dict{Symbol,Any}()
    optionString = ""
    chunks = WeaveChunk[]
    state = "code"

    for lineno = 1:length(lines)
        line = lines[lineno]
        if (m = match(doc_line, line)) != nothing && (m = match(opt_line, line)) == nothing
            line = replace(line, doc_start => "", count = 1)
            if startswith(line, " ")
                line = replace(line, " " => "", count = 1)
            end
            if state == "code" && strip(read) != ""
                chunk =
                    CodeChunk("\n" * strip(read), codeno, start_line, optionString, options)
                push!(chunks, chunk)
                codeno += 1
                read = ""
                start_line = lineno
            end
            state = "doc"
        elseif (m = match(opt_line, line)) != nothing
            start_line = lineno
            if state == "code" && strip(read) != ""
                chunk =
                    CodeChunk("\n" * strip(read), codeno, start_line, optionString, options)
                push!(chunks, chunk)
                read = ""
                codeno += 1
            end
            if state == "doc" && strip(read) != ""
                (docno > 1) && (read = "\n" * read) # Add whitespace to doc chunk. Needed for markdown output
                chunk = DocChunk(read, docno, start_line)
                push!(chunks, chunk)
                read = ""
                docno += 1
            end

            optionString = replace(line, opt_start => "", count = 1)
            # Get options
            options = Dict{Symbol,Any}()
            if length(optionString) > 0
                expr = Meta.parse(optionString)
                Base.Meta.isexpr(expr, :(=)) && (options[expr.args[1]] = expr.args[2])
                Base.Meta.isexpr(expr, :toplevel) &&
                    map(pushopt, fill(options, length(expr.args)), expr.args)
            end
            haskey(options, :label) && (options[:name] = options[:label])
            haskey(options, :name) || (options[:name] = nothing)

            state = "code"
            continue
        elseif state == "doc" # && strip(line) != "" && strip(read) != ""
            state = "code"
            (docno > 1) && (read = "\n" * read) # Add whitespace to doc chunk. Needed for markdown output
            chunk = DocChunk(read, docno, start_line)
            push!(chunks, chunk)
            options = Dict{Symbol,Any}()
            start_line = lineno
            read = ""
            docno += 1
        end
        read *= line * "\n"
    end

    # Handle the last chunk
    if state == "code"
        chunk = CodeChunk("\n" * strip(read), codeno, start_line, optionString, options)
        push!(chunks, chunk)
    else
        chunk = DocChunk(read, docno, start_line)
        push!(chunks, chunk)
    end

    return Dict(), chunks
end
