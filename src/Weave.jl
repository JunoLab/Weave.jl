module Weave
import Highlights
using Compat
using Requires

function __init__()
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" Base.include(Main, "plots.jl")
    @require Gadfly="c91e804a-d5a3-530f-b6f0-dfbca275c004" Base.include(Main, "gadfly.jl")
end

"""
`list_out_formats()`

List supported output formats
"""
function list_out_formats()
  for format = keys(formats)
      println(string(format,": ",  formats[format].description))
  end
end


"""
`tangle(source ; out_path=:doc, informat="noweb")`

Tangle source code from input document to .jl file.

* `informat`: `"noweb"` of `"markdown"`
* `out_path`: Path where the output is generated. Can be: `:doc`: Path of the source document, `:pwd`: Julia working directory,  `"somepath"`, directory name as a string e.g `"/home/mpastell/weaveout"`
or filename as string e.g. ~/outpath/outfile.jl.
"""
function tangle(source ; out_path=:doc, informat=:auto)
    doc = read_doc(source, informat)
    doc.cwd = get_cwd(doc, out_path)

    outname = get_outname(out_path, doc, ext = "jl")

    open(outname, "w") do io
    for chunk in doc.chunks
      if typeof(chunk) == CodeChunk
          options = merge(doc.chunk_defaults, chunk.options)
          if options[:tangle]
            write(io, chunk.content*"\n")
          end
      end
    end
  end
  doc.cwd == pwd()  && (outname = basename(outname))
  @info("Writing to file $outname")
end


"""
    weave(source ; doctype = :auto,
        informat=:auto, out_path=:doc, args = Dict(),
        mod::Union{Module, Symbol} = Main,
        fig_path = "figures", fig_ext = nothing,
        cache_path = "cache", cache=:off,
        template = nothing, highlight_theme = nothing, css = nothing,
        pandoc_options = "",
        latex_cmd = "xelatex")

Weave an input document to output file.

* `doctype`: :auto = set based on file extension or specify one of the supported formats.
  See `list_out_formats()`
* `informat`: :auto = set based on file extension or set to  `"noweb"`, `"markdown"` or  `script`
* `out_path`: Path where the output is generated. Can be: `:doc`: Path of the source document, `:pwd`:
   Julia working directory, `"somepath"`: output directory as a String e.g `"/home/mpastell/weaveout"` or filename as
   string e.g. ~/outpath/outfile.tex.
* `args`: dictionary of arguments to pass to document. Available as WEAVE_ARGS
* `mod`: Module where Weave `eval`s code. Defaults to `:sandbox`
   to create new sandbox module, you can also pass a module e.g. `Main`.
* `fig_path`: where figures will be generated, relative to out_path
* `fig_ext`: Extension for saved figures e.g. `".pdf"`, `".png"`. Default setting depends on `doctype`.
* `cache_path`: where of cached output will be saved.
* `cache`: controls caching of code: `:off` = no caching, `:all` = cache everything,
  `:user` = cache based on chunk options, `:refresh`, run all code chunks and save new cache.
* `throw_errors` if `false` errors are included in output document and the whole document is
    executed. if `true` errors are thrown when they occur.
* `template` : Template (file path) or MustacheTokens for md2html or md2tex formats.
* `highlight_theme` : Theme (Highlights.AbstractTheme) for used syntax highlighting
* `css` : CSS (file path) used for md2html format
* `pandoc_options` = String array of options to pass to pandoc for `pandoc2html` and
   `pandoc2pdf` formats e.g. ["--toc", "-N"]
* `latex_cmd` the command used to make pdf from .tex

**Note:** Run Weave from terminal and not using IJulia, Juno or ESS, they tend to mess with capturing output.
"""
function weave(source ; doctype = :auto,
        informat=:auto, out_path=:doc, args = Dict(),
        mod::Union{Module, Symbol} = :sandbox,
        fig_path = "figures", fig_ext = nothing,
        cache_path = "cache", cache=:off,
        throw_errors = false,
        template = nothing, highlight_theme = nothing, css = nothing,
        pandoc_options = String[]::Array{String},
        latex_cmd = "xelatex")

    doc = read_doc(source, informat)
    doctype == :auto && (doctype = detect_doctype(doc.source))
    doc.doctype = doctype

    # Read args from document header, overrides command line args
    if haskey(doc.header, "options")
        (doctype, informat, out_path, args, mod, fig_path, fig_ext,
        cache_path, cache, throw_errors, template, highlight_theme, css,
        pandoc_options, latex_cmd) = header_args(doc, out_path, mod,
                                    fig_ext, fig_path,
                                    cache_path, cache, throw_errors,
                                    template, highlight_theme, css,
                                    pandoc_options, latex_cmd)
    end

    template != nothing && (doc.template = template)
    highlight_theme != nothing && (doc.highlight_theme = highlight_theme)
    #theme != nothing && (doc.theme = theme) #Reserved for themes
    css != nothing && (doc.css = css)

    try
      doc = run(doc, doctype = doctype,
              mod = mod,
              out_path=out_path, args = args,
              fig_path = fig_path, fig_ext = fig_ext, cache_path = cache_path, cache=cache,
              throw_errors = throw_errors)
      formatted = format(doc)

      outname = get_outname(out_path, doc)

      open(outname, "w") do io
          write(io, formatted)
      end

      #Special for that need external programs
      if doc.doctype == "pandoc2html"
          mdname = outname
          outname = get_outname(out_path, doc, ext = "html")
          pandoc2html(formatted, doc, outname, pandoc_options)
          rm(mdname)
      elseif doc.doctype == "pandoc2pdf"
          mdname = outname
          outname = get_outname(out_path, doc, ext = "pdf")
          pandoc2pdf(formatted, doc, outname, pandoc_options)
          rm(mdname)
      elseif doc.doctype == "md2pdf"
          success = run_latex(doc, outname, latex_cmd)
          success && rm(doc.fig_path, force = true, recursive = true)
          success || return
          outname = get_outname(out_path, doc, ext = "pdf")
      end

      doc.cwd == pwd() && (outname = basename(outname))
      @info("Report weaved to $outname")
      return abspath(outname)
    #catch err
    #    @warn("Something went wrong during weaving")
    #    @error(sprint(showerror, err))
    #    return nothing
    finally
        doctype == :auto && (doctype = detect_doctype(doc.source))
        if occursin("2pdf", doctype)
            rm(doc.fig_path, force = true, recursive = true)
        elseif occursin("2html", doctype)
            rm(doc.fig_path, force = true, recursive = true)
        end
    end
end

function weave(doc::AbstractString, doctype::AbstractString)
    weave(doc, doctype=doctype)
end

"""
  notebook(source::String; out_path=:pwd, timeout=-1, nbconvert_options="", jupyter_path = "jupyter")

Convert Weave document `source` to Jupyter notebook and execute the code
using nbconvert. **Ignores** all chunk options

* `out_path`: Path where the output is generated. Can be: `:doc`: Path of the source document,
   `:pwd`: Julia working directory, `"somepath"`: Path as a
    String e.g `"/home/mpastell/weaveout"`
* `timeout`: nbconvert cell timeout in seconds. Defaults to -1 (no timeout)
* `nbconvert_options`: string of additional options to pass to nbconvert, such as `--allow-errors`
* `jupyter_path`: Path/command for the Jupyter you want to use. Defaults to "jupyter," which runs whatever is linked/alias to that.
"""
function notebook(source::String; out_path=:pwd, timeout=-1, nbconvert_options=[], jupyter_path = "jupyter")
  doc = read_doc(source)
  converted = convert_doc(doc, NotebookOutput())
  doc.cwd = get_cwd(doc, out_path)
  outfile = get_outname(out_path, doc, ext="ipynb")

  open(outfile, "w") do f
    write(f, converted)
  end

  @info("Running nbconvert")
  out = read(`$jupyter_path nbconvert --ExecutePreprocessor.timeout=$timeout --to notebook --execute $outfile  $nbconvert_options --output $outfile`, String)
end


"""
    include_weave(doc, informat=:auto)
    include_weave(m::Module, doc, informat=:auto)

Include code from Weave document calling `include_string` on
all code from doc. Code is run in the path of the include document.
"""
function include_weave(m::Module, source, informat=:auto)
    old_path = pwd()
    doc = read_doc(source, informat)
    cd(doc.path)
    try
        code = join([x.content for x in
            filter(x -> isa(x,Weave.CodeChunk), doc.chunks)], "\n")
        include_string(m, code)
    catch e
        throw(e)
    finally
        cd(old_path)
    end
end

include_weave(source, informat=:auto) = include_weave(Main, source, informat)

#Hooks to run before and after chunks, this is form IJulia,
#but note that Weave hooks take the chunk as input
const preexecute_hooks = Function[]
push_preexecute_hook(f::Function) = push!(preexecute_hooks, f)
pop_preexecute_hook(f::Function) = splice!(preexecute_hooks, findfirst(x -> x == f, preexecute_hooks))

const postexecute_hooks = Function[]
push_postexecute_hook(f::Function) = push!(postexecute_hooks, f)
pop_postexecute_hook(f::Function) = splice!(postexecute_hooks, findfirst(x -> x == f, postexecute_hooks))

include("chunks.jl")
include("config.jl")
include("WeaveMarkdown/markdown.jl")
include("display_methods.jl")
include("readers.jl")
include("run.jl")
include("cache.jl")
include("formatters.jl")
include("format.jl")
include("pandoc.jl")
include("writers.jl")


export weave, list_out_formats, tangle, convert_doc, notebook,
        set_chunk_defaults, get_chunk_defaults, restore_chunk_defaults,
        include_weave
end
