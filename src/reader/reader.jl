using JSON, YAML


"""
    read_doc(source, format = :auto)

Read the input document from `source` and parse it into [`WeaveDoc`](@ref).
"""
function read_doc(source, format = :auto)
    document = replace(read(source, String), "\r\n" => "\n") # fix line ending
    format === :auto && (format = detect_informat(source))
    chunks = parse_doc(document, format)
    return WeaveDoc(source, chunks)
end

function WeaveDoc(source, chunks)
    path, fname = splitdir(abspath(source))
    basename = splitext(fname)[1]

    header = parse_header(first(chunks))
    # get chunk defaults from header and update
    chunk_defaults = deepcopy(rcParams[:chunk_defaults])
    if haskey(header, WEAVE_OPTION_NAME)
        for key in keys(chunk_defaults)
            if (val = get(header[WEAVE_OPTION_NAME], string(key), nothing)) !== nothing
                chunk_defaults[key] = val
            end
        end
    end

    return WeaveDoc(
        source,
        basename,
        path,
        chunks,
        "",
        nothing,
        "",
        "",
        header,
        "",
        "",
        Highlights.Themes.DefaultTheme,
        "",
        chunk_defaults,
    )
end

"""
    detect_informat(source::AbstractString)

Detect Weave input format based on file extension of `source`.
"""
function detect_informat(source::AbstractString)
    ext = lowercase(last(splitext(source)))

    ext == ".jl" && return "script"
    ext == ".jmd" && return "markdown"
    ext == ".ipynb" && return "notebook"
    return "noweb"
end

function parse_doc(document, format)::Vector{WeaveChunk}
    return if format == "markdown"
        parse_markdown(document)
    elseif format == "noweb"
        parse_markdown(document, true)
    elseif format == "script"
        parse_script(document)
    elseif format == "notebook"
        parse_notebook(document)
    else
        error("unsupported format given: $(format)")
    end
end

function pushopt(options::Dict, expr::Expr)
    if Base.Meta.isexpr(expr, :(=))
        options[expr.args[1]] = expr.args[2]
    end
end

# inline
# ------

function DocChunk(text::AbstractString, number, start_line; notebook = false)
    # don't parse inline code in notebook
    content = notebook ? parse_inline(text) : parse_inlines(text)
    return DocChunk(content, number, start_line)
end

const INLINE_REGEX = r"`j\s+(.*?)`|^!\s(.*)$"m

function parse_inlines(text)::Vector{Inline}
    occursin(INLINE_REGEX, text) || return parse_inline(text)

    inline_chunks = eachmatch(INLINE_REGEX, text)
    s = 1
    e = 1
    res = Inline[]
    textno = 1
    codeno = 1

    for ic in inline_chunks
        s = ic.offset
        doc = InlineText(text[e:(s-1)], e, s - 1, textno)
        textno += 1
        push!(res, doc)
        e = s + lastindex(ic.match)
        ic.captures[1] !== nothing && (ctype = :inline)
        ic.captures[2] !== nothing && (ctype = :line)
        cap = filter(x -> x !== nothing, ic.captures)[1]
        push!(res, InlineCode(cap, s, e, codeno, ctype))
        codeno += 1
    end
    push!(res, InlineText(text[e:end], e, length(text), textno))

    return res
end

parse_inline(text) = Inline[InlineText(text, 1, length(text), 1)]

# headers
# -------

parse_header(chunk::CodeChunk) = Dict()

const HEADER_REGEX = r"^---$(?<header>((?!---).)+)^---$"ms

function parse_header(chunk::DocChunk)
    m = match(HEADER_REGEX, chunk.content[1].content)
    if m !== nothing
        header = YAML.load(string(m[:header]))
    else
        header = Dict()
    end
    return header
end


include("markdown.jl")
include("script.jl")
include("notebook.jl")
