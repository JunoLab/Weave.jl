function parse_markdown(document_body; is_pandoc = false)
    header_text, document_body, offset = separate_header_text(document_body)
    header = parse_header(header_text)
    code_start, code_end = if is_pandoc
        r"^<<(?<options>.*?)>>=\s*$",
        r"^@\s*$"
    else
        r"^[`~]{3}(\{?)julia\s*([;,\{]?)\s*(?<options>.*?)(\}|\s*)$",
        r"^[`~]{3}\s*$"
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
    offset = @static if VERSION ≥ v"1.4"
        count("\n", header_text)
    else
        count(c->c==='\n', header_text)
    end
    return header_text, replace(text, HEADER_REGEX => ""; count = 1), offset
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

    state = :doc
    doc_no = 0
    code_no = 0
    content = ""
    start_line = offset

    options = OptionDict()
    option_string = ""

    chunks = WeaveChunk[]
    for (line_no, line) in enumerate(lines)
        m = match(code_start, line)
        if !isnothing(m) && state === :doc
            state = :code

            option_string = isnothing(m[:options]) ? "" : strip(m[:options])
            options = parse_options(option_string)
            haskey(options, :label) && (options[:name] = options[:label])
            haskey(options, :name) || (options[:name] = nothing)

            isempty(strip(content)) || push!(chunks, DocChunk(content, doc_no += 1, start_line))

            start_line = line_no + offset
            content = ""
            continue
        end

        if occursin(code_end, line) && state === :code
            push!(chunks, CodeChunk(content, code_no += 1, start_line, option_string, options))

            start_line = line_no + offset
            content = ""
            state = :doc
            continue
        end

        content *= isone(line_no) ? line : string('\n', line)
    end

    # Remember the last chunk
    isempty(strip(content)) || push!(chunks, DocChunk(content, doc_no += 1, start_line))

    return chunks
end
