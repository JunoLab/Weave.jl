module Weave

using Highlights, Mustache, Requires, Pkg, REPL


# directories
const PKG_DIR = normpath(@__DIR__, "..")
const TEMPLATE_DIR = normpath(PKG_DIR, "templates")
const STYLESHEET_DIR = normpath(PKG_DIR, "stylesheets")
# keeps paths of sample documents for easy try
const EXAMPLE_FOLDER = normpath(PKG_DIR, "examples")

# constant names
const WEAVE_OPTION_NAME = "weave_options"
const WEAVE_OPTION_NAME_DEPRECATED = "options" # remove this when tagging v0.11
const WEAVE_OPTION_DEPRECATE_ID = "weave_option_duplicate_id"
const DEFAULT_FIG_PATH = "figures"

const WEAVE_VERSION = try
    'v' * Pkg.TOML.parsefile(normpath(PKG_DIR, "Project.toml"))["version"]
catch
    ""
end
weave_info() = WEAVE_VERSION, string(Date(now()))

function __init__()
    @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("plots.jl")
    @require Gadfly = "c91e804a-d5a3-530f-b6f0-dfbca275c004" include("gadfly.jl")
end

# utilitity functions
take2string!(io) = String(take!(io))
joinlines(lines) = join(lines, '\n')


include("types.jl")
include("config.jl")
include("WeaveMarkdown/markdown.jl")
include("display_methods.jl")
include("reader/reader.jl")
include("run.jl")
include("cache.jl")
include("rendering/rendering.jl")
include("writer/writer.jl")
include("converter.jl")


get_format(doctype::AbstractString) = FORMATS[doctype]

"""
    list_out_formats()

List supported output formats with its description.
"""
list_out_formats() = [k => v.description for (k,v) in FORMATS]

"""
    tangle(source::AbstractString; kwargs...)

Tangle source code from input document to .jl file.

## Keyword options

- `informat::Union{Nothing,AbstractString} = nothing`: Input document format. By default (i.e. given `nothing`), Weave will set it automatically based on file extension. You can also specify either of `"script"`, `"markdown"`, `"notebook"`, or `"noweb"`
- `out_path::Union{Symbol,AbstractString} = :doc`: Path where the output is generated can be either of:
  * `:doc`: Path of the source document (default)
  * `:pwd`: Julia working directory
  * `"somepath"`: `String` of output directory e.g. `"~/outdir"`, or of filename e.g. `"~/outdir/outfile.tex"`
"""
function tangle(
    source::AbstractString;
    out_path::Union{Symbol,AbstractString} = :doc,
    informat::Union{Nothing,AbstractString} = nothing,
)
    doc = WeaveDoc(source, informat)
    doc.cwd = get_cwd(doc, out_path)

    out_path = get_out_path(doc, out_path, "jl")

    open(out_path, "w") do io
        for chunk in doc.chunks
            if typeof(chunk) == CodeChunk
                options = merge(doc.chunk_defaults, chunk.options)
                options[:tangle] && write(io, chunk.content * "\n")
            end
        end
    end

    @info "Tangled to $(out_path)"
end

"""
    weave(source::AbstractString; kwargs...)

Weave an input document to output file.

## Keyword options

- `doctype::Union{Nothing,AbstractString} = nothing`: Output document format. By default (i.e. given `nothing`), Weave will set it automatically based on file extension. You can also manually specify it; see [`list_out_formats()`](@ref) for the supported formats
- `informat::Union{Nothing,AbstractString} = nothing`: Input document format. By default (i.e. given `nothing`), Weave will set it automatically based on file extension. You can also specify either of `"script"`, `"markdown"`, `"notebook"`, or `"noweb"`
- `out_path::Union{Symbol,AbstractString} = :doc`: Path where the output is generated can be either of:
  * `:doc`: Path of the source document (default)
  * `:pwd`: Julia working directory
  * `"somepath"`: `String` of output directory e.g. `"~/outdir"`, or of filename e.g. `"~/outdir/outfile.tex"`
- `args::Any = Dict()`: A runtime object that is available as `WEAVE_ARGS` while `weave`ing
- `mod::Union{Module,Nothing} = nothing`: Module where Weave `eval`s code. You can pass a `Module` object, otherwise create an new sandbox module.
- `fig_path::Union{Nothing,AbstractString} = nothing`: Where figures will be generated, relative to `out_path`. By default (i.e. given `nothing`), Weave will automatically create `$(DEFAULT_FIG_PATH)` directory.
- `fig_ext::Union{Nothing,AbstractString} = nothing`: Extension for saved figures e.g. `".pdf"`, `".png"`. Default setting depends on `doctype`
- `cache_path::AbstractString = "cache"`: Where of cached output will be saved
- `cache::Symbol = :off`: Controls caching of code:
  * `:off` means no caching (default)
  * `:all` caches everything
  * `:user` caches based on chunk options
  * `:refresh` runs all code chunks and save new cache
- `template::Union{Nothing,AbstractString,Mustache.MustacheTokens} = nothing`: Template (file path) or `Mustache.MustacheTokens`s for `md2html` or `md2tex` formats
- `css::Union{Nothing,AbstractString} = nothing`: Path of a CSS file used for md2html format
- `highlight_theme::Union{Nothing,Type{<:Highlights.AbstractTheme}} = nothing`: Theme used for syntax highlighting (defaults to `Highlights.Themes.DefaultTheme`)
- `pandoc_options::Vector{<:AbstractString} = $(DEFAULT_PANDOC_OPTIONS)`: `String`s of options to pass to pandoc for `pandoc2html` and `pandoc2pdf` formats, e.g. `["--toc", "-N"]`
- `latex_cmd::Vector{<:AbstractString} = $(DEFAULT_LATEX_CMD)`: The command used to make PDF file from .tex
- `keep_unicode::Bool = false`: If `true`, do not convert unicode characters to their respective latex representation. This is especially useful if a font and tex-engine with support for unicode characters are used

!!! note
    Run Weave from terminal and try to avoid weaving from IJulia or ESS; they tend to mess with capturing output.
"""
function weave(
    source::AbstractString;
    doctype::Union{Nothing,AbstractString} = nothing,
    informat::Union{Nothing,AbstractString} = nothing,
    out_path::Union{Symbol,AbstractString} = :doc,
    args::Any = Dict(),
    mod::Union{Module,Nothing} = nothing,
    fig_path::Union{Nothing,AbstractString} = nothing,
    fig_ext::Union{Nothing,AbstractString} = nothing,
    cache_path::AbstractString = "cache",
    cache::Symbol = :off,
    template::Union{Nothing,AbstractString,Mustache.MustacheTokens} = nothing,
    css::Union{Nothing,AbstractString} = nothing, # TODO: rename to `stylesheet`
    highlight_theme::Union{Nothing,Type{<:Highlights.AbstractTheme}} = nothing,
    pandoc_options::Vector{<:AbstractString} = DEFAULT_PANDOC_OPTIONS,
    latex_cmd::Vector{<:AbstractString} = DEFAULT_LATEX_CMD,
    keep_unicode::Bool = false,
)
    doc = WeaveDoc(source, informat)

    # run document
    # ------------

    # overwrites options with those specified in header, that are needed for running document
    # NOTE: these YAML options can NOT be given dynamically
    weave_options = get(doc.header, WEAVE_OPTION_NAME, nothing)
    if haskey(doc.header, WEAVE_OPTION_NAME_DEPRECATED)
        @warn "Weave: `options` key is deprecated. Use `weave_options` key instead." _id = WEAVE_OPTION_DEPRECATE_ID maxlog = 1
        weave_options = get(doc.header, WEAVE_OPTION_NAME_DEPRECATED, nothing)
    end

    if !isnothing(weave_options)
        doctype = get(weave_options, "doctype", doctype)
        specific_options!(weave_options, doctype)
        if haskey(weave_options, "out_path")
            out_path = let
                out_path = weave_options["out_path"]
                if out_path == ":doc" || out_path == ":pwd"
                    Symbol(out_path)
                else
                    normpath(dirname(source), out_path) # resolve relative to this document
                end
            end
        end
        mod = get(weave_options, "mod", mod)
        mod isa AbstractString && (mod = Main.eval(Meta.parse(mod)))
        fig_path = get(weave_options, "fig_path", fig_path)
        fig_ext = get(weave_options, "fig_ext", fig_ext)
        cache_path = get(weave_options, "cache_path", cache_path)
        cache = Symbol(get(weave_options, "cache", cache))
    end

    doc = run_doc(
        doc;
        doctype = doctype,
        mod = mod,
        out_path = out_path,
        args = args,
        fig_path = fig_path,
        fig_ext = fig_ext,
        cache_path = cache_path,
        cache = cache,
    )

    # overwrites options with those specified in header, that are needed for rendering/writing document
    # NOTE: these YAML options can be given dynamically
    if !isnothing(weave_options)
        if haskey(weave_options, "template")
            template = weave_options["template"]
            # resolve relative to this document
            template isa AbstractString && (template = normpath(dirname(source), template))
        end
        if haskey(weave_options, "css")
            css = weave_options["css"]
            # resolve relative to this document
            css isa AbstractString && (css = normpath(dirname(source), css))
        end
        highlight_theme = get(weave_options, "highlight_theme", highlight_theme)
        keep_unicode = get(weave_options, "keep_unicode", keep_unicode)
        latex_cmd = get(weave_options, "latex_cmd", latex_cmd)
        pandoc_options = get(weave_options, "pandoc_options", pandoc_options)
    end

    set_format_options!(
        doc;
        # general
        template = template,
        highlight_theme = highlight_theme,
        css = css,
        # pandoc
        pandoc_options = pandoc_options,
        # latex
        keep_unicode = keep_unicode,
        latex_cmd = latex_cmd,
    )

    # render document
    # ---------------
    rendered = render_doc(doc)

    # write documents
    # ---------------
    out_path = write_doc(doc, rendered, get_out_path(doc, out_path))

    @info "Weaved to $(out_path)"
    return out_path
end

weave(doc::AbstractString, doctype::Union{Symbol,AbstractString}; kwargs...) =
    weave(doc; doctype = doctype, kwargs...)

function specific_options!(weave_options, doctype)
    fmts = keys(FORMATS)
    for (k,v) in weave_options
        if k in fmts
            k == doctype && merge!(weave_options, v)
            delete!(weave_options, k)
        end
    end
end

get_out_path(doc, out_path, ext::Nothing = nothing) = get_out_path(doc, out_path, doc.format.extension)
get_out_path(doc, out_path, ext) = abspath(get_cwd(doc, out_path), string(doc.basename , '.', ext))

"""
    notebook(source::AbstractString; kwargs...)

Convert Weave document `source` to Jupyter Notebook and execute the code
using [`nbconvert`](https://nbconvert.readthedocs.io/en/latest/).
**Ignores** all chunk options.

## Keyword options

- `out_path::Union{Symbol,AbstractString} = :pwd`: Path where the output is generated can be either of:
  * `:doc`: Path of the source document
  * `:pwd`: Julia working directory (default)
  * `"somepath"`: `String` of output directory e.g. `"~/outdir"`, or of filename e.g. `"~/outdir/outfile.tex"`
- `timeout = -1`: nbconvert cell timeout in seconds. Defaults to `-1` (no timeout)
- `nbconvert_options::AbstractString = ""`: `String` of additional options to pass to nbconvert, such as `"--allow-errors"`
- `jupyter_path::AbstractString = "jupyter"`: Path/command for the Jupyter you want to use. Defaults to `"jupyter"`, which runs whatever is linked/alias to that

!!! warning
    The code is _**not**_ executed by Weave, but by [`nbconvert`](https://nbconvert.readthedocs.io/en/latest/).
    This means that the output doesn't necessarily always work properly; see [#116](https://github.com/JunoLab/Weave.jl/issues/116).

!!! note
    In order to _just_ convert Weave document to Jupyter Notebook,
    use [`convert_doc`](@ref) instead.
"""
function notebook(
    source::AbstractString;
    out_path::Union{Symbol,AbstractString} = :pwd,
    timeout = -1,
    nbconvert_options::AbstractString = "",
    jupyter_path::AbstractString = "jupyter",
)
    doc = WeaveDoc(source)
    converted = convert_to_notebook(doc)
    doc.cwd = get_cwd(doc, out_path)
    out_path = get_out_path(doc, out_path, "ipynb")

    write(out_path, converted)

    @info "Running nbconvert ..."
    return read(
        `$jupyter_path nbconvert --ExecutePreprocessor.timeout=$timeout --to notebook --execute $(out_path)  $nbconvert_options --output $(out_path)`,
        String,
    )
end

"""
    include_weave(source::AbstractString, informat::Union{Nothing,AbstractString} = nothing)
    include_weave(m::Module, source::AbstractString, informat::Union{Nothing,AbstractString} = nothing)

Include code from Weave document calling `include_string` on all code from doc.
Code is run in the path of the include document.
"""
function include_weave(
    m::Module,
    source::AbstractString,
    informat::Union{Nothing,AbstractString} = nothing,
)
    old_path = pwd()
    doc = WeaveDoc(source, informat)
    cd(dirname(doc.path))
    try
        code = join(
            [x.content for x in filter(x -> isa(x, Weave.CodeChunk), doc.chunks)],
            "\n",
        )
        include_string(m, code)
    catch err
        throw(err)
    finally
        cd(old_path)
    end
    return nothing
end

include_weave(source, informat = nothing) = include_weave(Main, source, informat)


export weave,
    list_out_formats,
    tangle,
    convert_doc,
    notebook,
    set_chunk_defaults!,
    get_chunk_defaults,
    restore_chunk_defaults!,
    include_weave

end
