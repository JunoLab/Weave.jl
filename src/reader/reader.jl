using JSON, YAML


function WeaveDoc(source, informat = nothing, doctype = nothing)
    path, fname = splitdir(abspath(source))
    basename = splitext(fname)[1]

    isnothing(informat) && (informat = detect_informat(source))
    header, chunks = parse_doc(read(source, String), informat)

    isnothing(doctype) && (doctype = detect_doctype(source))

    # update default chunk options from header
    chunk_defaults = deepcopy(get_chunk_defaults())
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
        doctype,
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
    detect_informat(path)

Detect Weave input format based on file extension of `path`.
"""
function detect_informat(path)
    ext = lowercase(last(splitext(path)))

    ext == ".jl" && return "script"
    ext == ".jmd" && return "markdown"
    ext == ".ipynb" && return "notebook"
    return "noweb"
end

function parse_doc(document, informat)
    document = replace(document, "\r\n" => "\n") # normalize line ending

    header_text, document = separate_header_text(document)

    return parse_header(header_text),
        informat == "markdown" ? parse_markdown(document) :
        informat == "noweb" ? parse_markdown(document, true) :
        informat == "script" ? parse_script(document) :
        informat == "notebook" ? parse_notebook(document) :
        error("unsupported input format given: $informat")
end

function pushopt(options::Dict, expr::Expr)
    if Base.Meta.isexpr(expr, :(=))
        options[expr.args[1]] = expr.args[2]
    end
end

"""
    detect_doctype(path)

Detect the output format based on file extension.
"""
function detect_doctype(path)
    _, ext = lowercase.(splitext(path))

    match(r"^\.(jl|.?md|ipynb)", ext) !== nothing && return "md2html"
    ext == ".rst" && return "rst"
    ext == ".tex" && return "texminted"
    ext == ".txt" && return "asciidoc"

    return "pandoc"
end

# inline
# ------

function DocChunk(text::AbstractString, number, start_line; notebook = false)
    # don't parse inline code in notebook
    content = notebook ? parse_inline(text) : parse_inlines(text)
    return DocChunk(content, number, start_line)
end

const   INLINE_REGEX = r"`j\s+(.*?)`"
const INLINE_REGEXES = r"`j\s+(.*?)`|^!\s(.*)$"m

function parse_inlines(text)::Vector{Inline}
    occursin(INLINE_REGEXES, text) || return parse_inline(text)

    inline_chunks = eachmatch(INLINE_REGEXES, text)
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

const HEADER_REGEX = r"^---$(?<header>((?!---).)+)^---$"ms

# TODO: non-Weave headers should keep live in a doc
# separates header section from `text`
function separate_header_text(text)
    m = match(HEADER_REGEX, text)
    isnothing(m) && return "", text
    return m[:header], replace(text, HEADER_REGEX => ""; count = 1)
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

include("markdown.jl")
include("script.jl")
include("notebook.jl")
