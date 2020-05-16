function parse_markdown(document_body; is_pandoc = false)
    if is_pandoc
        header = Dict()
        offset = 0
        code_start = r"^<<(?<options>.*?)>>=\s*$"
        code_end = r"^@\s*$"
    else
        header_text, document_body, offset = separate_header_text(document_body)
        header = parse_header(header_text)
        code_start = r"^[`~]{3}(?:\{?)julia(?:;?)\s*(?<options>.*?)(\}|\s*)$"
        code_end = r"^[`~]{3}\s*$"
    end
    return header, parse_markdown_body(document_body, code_start, code_end, offset)
end

# headers
# -------

const HEADER_REGEX = r"^---$(?<header>((?!---).)+)^---$"ms

# TODO: non-Weave headers should keep live in a doc
# separates header section from `text`
function separate_header_text(text)
    m = match(HEADER_REGEX, text)
    isnothing(m) && return "", text, 0
    header_text = m[:header]
    return header_text, replace(text, HEADER_REGEX => ""; count = 1), count("\n", header_text)
end

# HACK:
# YAML.jl can't parse text including ``` characters, so first replace all the inline code
# with these temporary code start/end string
const HEADER_INLINE_START = "<weave_header_inline_start>"
const   HEADER_INLINE_END = "<weave_header_inline_end>"

function parse_header(header_text)
    isempty(header_text) && return Dict()
    pat = INLINE_REGEX => SubstitutionString("$(HEADER_INLINE_START)\\1$(HEADER_INLINE_END)")
    header_text = replace(header_text, pat)
    return YAML.load(header_text)
end

# body
# ----

function parse_markdown_body(document_body, code_start, code_end, offset)
    lines = split(document_body, '\n')

    state = "doc"

    docno = 1
    codeno = 1
    content = ""
    start_line = offset

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
            start_line = lineno + offset

            continue
        end

        if occursin(code_end, line) && state == "code"
            chunk = CodeChunk(content, codeno, start_line, optionString, options)

            codeno += 1
            start_line = lineno + offset
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
