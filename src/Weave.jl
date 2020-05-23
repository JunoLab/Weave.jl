module Weave

using Highlights, Mustache, Requires


const PKG_DIR = normpath(@__DIR__, "..")
const TEMPLATE_DIR = normpath(PKG_DIR, "templates")
const WEAVE_OPTION_NAME = "weave_options"
const WEAVE_OPTION_NAME_DEPRECATED = "options" # remove this when tagging v0.11

# keeps paths of sample documents for easy try
const EXAMPLE_FOLDER = normpath(PKG_DIR, "examples")


function __init__()
    @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("plots.jl")
    @require Gadfly = "c91e804a-d5a3-530f-b6f0-dfbca275c004" include("gadfly.jl")
end

@static @isdefined(isnothing) || begin
    isnothing(::Any) = false
    isnothing(::Nothing) = true
end
take2string!(io) = String(take!(io))

"""
    list_out_formats()

List supported output formats
"""
function list_out_formats()
    for format in keys(formats)
        println(string(format, ": ", formats[format].description))
    end
end

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

    outname = get_outname(out_path, doc, ext = "jl")

    open(outname, "w") do io
        for chunk in doc.chunks
            if typeof(chunk) == CodeChunk
                options = merge(doc.chunk_defaults, chunk.options)
                options[:tangle] && write(io, chunk.content * "\n")
            end
        end
    end
    doc.cwd == pwd() && (outname = basename(outname))
    @info("Writing to file $outname")
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
- `args::Dict = Dict()`: Arguments to be passed to the weaved document; will be available as `WEAVE_ARGS` in the document
- `mod::Union{Module,Nothing} = nothing`: Module where Weave `eval`s code. You can pass a `Module` object, otherwise create an new sandbox module.
- `fig_path::AbstractString = "figures"`: Where figures will be generated, relative to `out_path`
- `fig_ext::Union{Nothing,AbstractString} = nothing`: Extension for saved figures e.g. `".pdf"`, `".png"`. Default setting depends on `doctype`
- `cache_path::AbstractString = "cache"`: Where of cached output will be saved
- `cache::Symbol = :off`: Controls caching of code:
  * `:off` means no caching (default)
  * `:all` caches everything
  * `:user` caches based on chunk options
  * `:refresh` runs all code chunks and save new cache
- `throw_errors::Bool = false`: If `false` errors are included in output document and the whole document is executed. If `true` errors are thrown when they occur
- `template::Union{Nothing,AbstractString,Mustache.MustacheTokens} = nothing`: Template (file path) or `Mustache.MustacheTokens`s for `md2html` or `md2tex` formats
- `css::Union{Nothing,AbstractString} = nothing`: Path of a CSS file used for md2html format
- `highlight_theme::Union{Nothing,Type{<:Highlights.AbstractTheme}} = nothing`: Theme used for syntax highlighting (defaults to `Highlights.Themes.DefaultTheme`)
- `pandoc_options::Vector{<:AbstractString} = String[]`: `String`s of options to pass to pandoc for `pandoc2html` and `pandoc2pdf` formats, e.g. `["--toc", "-N"]`
- `latex_cmd::AbstractString = "xelatex"`: The command used to make PDF file from .tex
- `keep_unicode::Bool = false`: If `true`, do not convert unicode characters to their respective latex representation. This is especially useful if a font and tex-engine with support for unicode characters are used

!!! note
    Run Weave from terminal and try to avoid weaving from IJulia or ESS; they tend to mess with capturing output.
"""
function weave(
    source::AbstractString;
    doctype::Union{Nothing,AbstractString} = nothing,
    informat::Union{Nothing,AbstractString} = nothing,
    out_path::Union{Symbol,AbstractString} = :doc,
    args::Dict = Dict(),
    mod::Union{Module,Nothing} = nothing,
    fig_path::AbstractString = "figures",
    fig_ext::Union{Nothing,AbstractString} = nothing,
    cache_path::AbstractString = "cache",
    cache::Symbol = :off,
    throw_errors::Bool = false,
    template::Union{Nothing,AbstractString,Mustache.MustacheTokens} = nothing,
    css::Union{Nothing,AbstractString} = nothing, # TODO: rename to `stylesheet`
    highlight_theme::Union{Nothing,Type{<:Highlights.AbstractTheme}} = nothing,
    pandoc_options::Vector{<:AbstractString} = String[],
    latex_cmd::AbstractString = "xelatex",
    keep_unicode::Bool = false,
)
    doc = WeaveDoc(source, informat)

    # run document
    # ------------

    # overwrites options with those specified in header, that are needed for running document
    # NOTE: these YAML options can NOT be given dynamically
    weave_options = get(doc.header, WEAVE_OPTION_NAME, nothing)
    if haskey(doc.header, WEAVE_OPTION_NAME_DEPRECATED)
        @warn "Weave: `options` key is deprecated. Use `weave_options` key instead."
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
        throw_errors = get(weave_options, "throw_errors", throw_errors)
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
        throw_errors = throw_errors,
    )

    # format document
    # ---------------

    # overwrites options with those specified in header, that are needed for formatting document
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
        pandoc_options = get(weave_options, "pandoc_options", pandoc_options)
        latex_cmd = get(weave_options, "latex_cmd", latex_cmd)
        keep_unicode = get(weave_options, "keep_unicode", keep_unicode)
    end

    get!(doc.format.formatdict, :keep_unicode, keep_unicode)
    rendered = format(doc, template, highlight_theme; css = css)

    outname = get_outname(out_path, doc)

    open(io->write(io,rendered), outname, "w")

    # document generation via external programs
    doctype = doc.doctype
    if doctype == "pandoc2html"
        mdname = outname
        outname = get_outname(out_path, doc, ext = "html")
        pandoc2html(rendered, doc, highlight_theme, outname, pandoc_options)
        rm(mdname)
    elseif doctype == "pandoc2pdf"
        mdname = outname
        outname = get_outname(out_path, doc, ext = "pdf")
        pandoc2pdf(rendered, doc, outname, pandoc_options)
        rm(mdname)
    elseif doctype == "md2pdf"
        run_latex(doc, outname, latex_cmd)
        outname = get_outname(out_path, doc, ext = "pdf")
    end

    doc.cwd == pwd() && (outname = basename(outname))
    @info "Report weaved to $outname"
    return abspath(outname)
end

weave(doc::AbstractString, doctype::Union{Symbol,AbstractString}; kwargs...) =
    weave(doc; doctype = doctype, kwargs...)

function specific_options!(weave_options, doctype)
    fmts = keys(formats)
    for (k,v) in weave_options
        if k in fmts
            k == doctype && merge!(weave_options, v)
            delete!(weave_options, k)
        end
    end
end

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
    This means that the output doesn't necessarily always work properly; see [#116](https://github.com/mpastell/Weave.jl/issues/116).

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
    outfile = get_outname(out_path, doc, ext = "ipynb")

    open(outfile, "w") do f
        write(f, converted)
    end

    @info "Running nbconvert"
    return read(
        `$jupyter_path nbconvert --ExecutePreprocessor.timeout=$timeout --to notebook --execute $outfile  $nbconvert_options --output $outfile`,
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
    cd(doc.path)
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

# Hooks to run before and after chunks, this is form IJulia,
# but note that Weave hooks take the chunk as input
const preexecute_hooks = Function[]
push_preexecute_hook(f::Function) = push!(preexecute_hooks, f)
pop_preexecute_hook(f::Function) =
    splice!(preexecute_hooks, findfirst(x -> x == f, preexecute_hooks))

const postexecute_hooks = Function[]
push_postexecute_hook(f::Function) = push!(postexecute_hooks, f)
pop_postexecute_hook(f::Function) =
    splice!(postexecute_hooks, findfirst(x -> x == f, postexecute_hooks))

include("types.jl")
include("config.jl")
include("WeaveMarkdown/markdown.jl")
include("display_methods.jl")
include("reader/reader.jl")
include("run.jl")
include("cache.jl")
include("formatters.jl")
include("format.jl")
include("pandoc.jl")
include("converter.jl")

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
