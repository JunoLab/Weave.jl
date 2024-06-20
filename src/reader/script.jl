function parse_script(document_body)
    header_text, document_body, offset = separate_header_text_jl(document_body)
    header_text = replace(header_text, r"\n(#')|(#%%)|(# %%)" => "\n")
    return parse_header(header_text), parse_script_body(document_body)
end

# headers
# -------

const HEADER_REGEX_JL = r"^(?:#'|#%%|# %%)\s*---$(?<header>((?!---).)+)^(?:#'|#%%|# %%)\s*---$"ms

function separate_header_text_jl(text)
    m = match(HEADER_REGEX_JL, text)
    isnothing(m) && return "", text, 0
    header_text = m[:header]
    offset = @static if VERSION ≥ v"1.4"
        count("\n", header_text)
    else
        count(c->c==='\n', header_text)
    end
    return header_text, replace(text, HEADER_REGEX_JL => ""; count = 1), offset
end

# body
# ----

function parse_script_body(document_body)
    lines = split(document_body, '\n')

    doc_line = r"(^#'.*)|(^#%%.*)|(^# %%.*)"
    doc_start = r"(^#')|(^#%%)|(^# %%)"
    opt_line = r"(^#\+.*$)|(^#%%\+.*$)|(^# %%\+.*$)"
    opt_start = r"(^#\+)|(^#%%\+)|(^# %%\+)"

    content = ""
    state = :code
    doc_no = 0
    code_no = 0
    start_line = 1

    options = OptionDict()
    option_string = ""

    chunks = WeaveChunk[]
    for (line_no, line) in enumerate(lines)
        if (m = match(doc_line, line)) !== nothing && (m = match(opt_line, line)) === nothing
            line = replace(line, doc_start => "", count = 1)
            startswith(line, ' ') && (line = replace(line, ' ' => "", count = 1))
            if state === :code && !isempty(strip(content))
                push!(chunks, CodeChunk(string('\n', strip(content)), code_no += 1, start_line, option_string, options))
                content = ""
                start_line = line_no
            end
            state = :doc
        elseif (m = match(opt_line, line)) !== nothing
            start_line = line_no
            if state === :code && !isempty(strip(content))
                push!(chunks, CodeChunk(string('\n', strip(content)), code_no += 1, start_line, option_string, options))
                content = ""
            end
            if state === :doc && !isempty(strip(content))
                iszero(doc_no) || (content = string('\n', content)) # Add whitespace to doc chunk. Needed for markdown output
                push!(chunks, DocChunk(content, doc_no += 1, start_line))
                content = ""
            end

            option_string = replace(line, opt_start => "", count = 1)
            options = parse_options(option_string)
            haskey(options, :label) && (options[:name] = options[:label])
            haskey(options, :name) || (options[:name] = nothing)

            state = :code
            continue
        elseif state === :doc # && strip(line) != "" && strip(content) != ""
            state = :code
            iszero(doc_no) || (content = string('\n', content)) # Add whitespace to doc chunk. Needed for markdown output
            push!(chunks, DocChunk(content, doc_no += 1, start_line))
            content = ""

            options = Dict{Symbol,Any}()
            start_line = line_no
        end
        content *= string(line, '\n')
    end

    # Handle the last chunk
    chunk = state === :code ?
        CodeChunk(string('\n', strip(content)), code_no, start_line, option_string, options) :
        DocChunk(content, doc_no, start_line)
    push!(chunks, chunk)

    return chunks
end
