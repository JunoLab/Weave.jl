using YAML


function WeaveDoc(source, informat = nothing)
    path, fname = splitdir(abspath(source))
    basename = splitext(fname)[1]

    isnothing(informat) && (informat = detect_informat(source))
    header, chunks = parse_doc(read(source, String), informat)

    # update default chunk options from header
    chunk_defaults = deepcopy(get_chunk_defaults())
    if (weave_options = get(header, WEAVE_OPTION_NAME, nothing)) !== nothing
        for key in keys(chunk_defaults)
            if (val = get(weave_options, string(key), nothing)) !== nothing
                chunk_defaults[key] = val
            end
        end
    end
    if haskey(header, WEAVE_OPTION_NAME_DEPRECATED)
        @warn "Weave: `options` key is deprecated. Use `weave_options` key instead." _id = WEAVE_OPTION_DEPRECATE_ID maxlog = 1
        for key in keys(chunk_defaults)
            if (val = get(header[WEAVE_OPTION_NAME_DEPRECATED], string(key), nothing)) !== nothing
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

    return informat == "markdown" ? parse_markdown(document) :
        informat == "noweb" ? parse_markdown(document; is_pandoc = true) :
        informat == "script" ? parse_script(document) :
        informat == "notebook" ? parse_notebook(document) :
        error("unsupported input format given: $informat")
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

# handle code units correctly !
function parse_inlines(str)
    ret = Inline[]
    s = 1
    code_no = text_no = 0
    for m in eachmatch(INLINE_REGEXES, str)
        e = m.offset
        push!(ret, InlineText((str[s:prevind(str,e)]), text_no += 1))
        i = findfirst(!isnothing, m.captures)
        push!(ret, InlineCode(m.captures[i], code_no += 1, isone(i) ? :inline : :line))
        s = e + ncodeunits(m.match)
    end
    push!(ret, InlineText(str[s:end], text_no += 1))
    return ret
end

parse_inline(str) = Inline[InlineText(str, 1)]

# options
# -------

const OptionDict = Dict{Symbol,Any}

function parse_options(str)::OptionDict
    str = string('(', str, ')')
    ex = Meta.parse(str)
    nt = if Meta.isexpr(ex, (
        :block, # "(k1 = v1; k2 = v2, ...)"
        :tuple, # "(k1 = v1, k2 = v2, ...)"
    ))
        eval(Expr(:tuple, filter(is_valid_kv, ex.args)...))
    elseif is_valid_kv(ex) # "(k = v)"
        eval(Expr(:tuple, ex))
    else
        NamedTuple{}()
    end
    return dict(nt)
end

is_valid_kv(x) = Meta.isexpr(x, :(=))
dict(nt) = Dict((k => v for (k,v) in zip(keys(nt), values(nt))))
nt(dict) = NamedTuple{(Symbol.(keys(dict))...,)}((collect(values(dict))...,))

# each input format
# -----------------

include("markdown.jl")
include("script.jl")
include("notebook.jl")
