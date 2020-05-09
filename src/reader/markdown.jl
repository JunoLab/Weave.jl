"""
    parse_markdown(document_body, is_pandoc = false)::Vector{WeaveChunk}
    parse_markdown(document_body, code_start, code_end)::Vector{WeaveChunk}

Parses Weave markdown and returns [`WeaveChunk`](@ref)s.
"""
function parse_markdown end

function parse_markdown(document_body, is_pandoc = false)::Vector{WeaveChunk}
    code_start, code_end = if is_pandoc
        r"^<<(?<options>.*?)>>=\s*$",
        r"^@\s*$"
    else
        r"^[`~]{3}(?:\{?)julia(?:;?)\s*(?<options>.*?)(\}|\s*)$",
        r"^[`~]{3}\s*$"
    end
    return parse_markdown(document_body, code_start, code_end)
end

function parse_markdown(document_body, code_start, code_end)::Vector{WeaveChunk}
    lines = split(document_body, '\n')

    state = "doc"

    docno = 1
    codeno = 1
    content = ""
    start_line = 0

    options = Dict()
    optionString = ""
    chunks = WeaveChunk[]
    for (lineno, line) in enumerate(lines)
        m = match(code_start, line)
        if !isnothing(m) && state == "doc"
            state = "code"
            if m.captures[1] == nothing
                optionString = ""
            else
                optionString = strip(m.captures[1])
            end

            options = Dict{Symbol,Any}()
            if length(optionString) > 0
                expr = Meta.parse(optionString)
                Base.Meta.isexpr(expr, :(=)) && (options[expr.args[1]] = expr.args[2])
                Base.Meta.isexpr(expr, :toplevel) &&
                    map(pushopt, fill(options, length(expr.args)), expr.args)
            end
            haskey(options, :label) && (options[:name] = options[:label])
            haskey(options, :name) || (options[:name] = nothing)

            if !isempty(strip(content))
                chunk = DocChunk(content, docno, start_line)
                docno += 1
                push!(chunks, chunk)
            end

            content = ""
            start_line = lineno

            continue
        end

        if occursin(code_end, line) && state == "code"
            chunk = CodeChunk(content, codeno, start_line, optionString, options)

            codeno += 1
            start_line = lineno
            content = ""
            state = "doc"
            push!(chunks, chunk)
            continue
        end

        if lineno == 1
            content *= line
        else
            content *= "\n" * line
        end
    end

    # Remember the last chunk
    if strip(content) != ""
        chunk = DocChunk(content, docno, start_line)
        # chunk =  Dict{Symbol,Any}(:type => "doc", :content => content,
        #                                 :number =>  docno, :start_line => start_line)
        push!(chunks, chunk)
    end
    return chunks
end
