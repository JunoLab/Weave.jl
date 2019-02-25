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
          options = merge(rcParams[:chunk_defaults], chunk.options)
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
* `template` : Template (file path) for md2html or md2tex formats.
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
    highlight_theme != nothing && (doc.highlight_theme = highlight_theme)
    #theme != nothing && (doc.theme = theme) #Reserved for themes
    css != nothing && (doc.css = css)
    template != nothing && (doc.template = template)

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
    #    catch err
    #    @warn("Something went wrong during weaving")
    #    println(e)
    finally
        doctype == :auto && (doctype = detect_doctype(doc.source))
        if occursin("pandoc2pdf", doctype) && cache == :off
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
  notebook(source::String, out_path=:pwd)

Convert Weave document `source` to Jupyter notebook and execute the code
using nbconvert. Requires IJulia. **Ignores** all chunk options

* `out_path`: Path where the output is generated. Can be: `:doc`: Path of the source document,
   `:pwd`: Julia working directory, `"somepath"`: Path as a
    String e.g `"/home/mpastell/weaveout"`
* nbconvert cell timeout in seconds. Defaults to -1 (no timeout)
"""
function notebook(source::String, out_path=:pwd, timeout=-1)
  doc = read_doc(source)
  converted = convert_doc(doc, NotebookOutput())
  doc.cwd = get_cwd(doc, out_path)
  outfile = get_outname(out_path, doc, ext="ipynb")

  open(outfile, "w") do f
    write(f, converted)
  end

  @info("Running nbconvert")
  eval(Meta.parse("using IJulia"))
  out = read(`$(IJulia.jupyter)-nbconvert --ExecutePreprocessor.timeout=$timeout --to notebook --execute $outfile --output $outfile`, String)
end

"""
    include_weave(doc, informat=:auto)

Include code from Weave document calling `include_string` on
all code from doc. Code is run in the path of the include document.
"""
function include_weave(source, informat=:auto)
  old_path = pwd()
  doc = read_doc(source, informat)
  cd(doc.path)
  try
    code = join([x.content for x in
      filter(x -> isa(x,Weave.CodeChunk), doc.chunks)], "\n")
    include_string(code)
  catch e
    cd(old_path)
    throw(e)
  end
end

#Hooks to run before and after chunks, this is form IJulia,
#but note that Weave hooks take the chunk as input
const preexecute_hooks = Function[]
push_preexecute_hook(f::Function) = push!(preexecute_hooks, f)
pop_preexecute_hook(f::Function) = splice!(preexecute_hooks, findfirst(preexecute_hooks, f))

const postexecute_hooks = Function[]
push_postexecute_hook(f::Function) = push!(postexecute_hooks, f)
pop_postexecute_hook(f::Function) = splice!(postexecute_hooks, findfirst(postexecute_hooks, f))

include("config.jl")
include("chunks.jl")
include("display_methods.jl")
include("readers.jl")
include("run.jl")
include("cache.jl")
include("formatters.jl")
include("Markdown2HTML.jl")
include("format.jl")
include("pandoc.jl")
include("writers.jl")



export weave, list_out_formats, tangle, convert_doc, notebook,
        set_chunk_defaults, get_chunk_defaults, restore_chunk_defaults,
        include_weave
end
