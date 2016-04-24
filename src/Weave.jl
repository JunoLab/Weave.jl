module Weave
using Compat

#Contains report global properties
type Report <: Display
  cwd::AbstractString
  basename::AbstractString
  formatdict::Dict{Symbol,Any}
  pending_code::AbstractString
  cur_result::AbstractString
  fignum::Int
  figures::Array{AbstractString}
  term_state::Symbol
  cur_chunk
end

function Report(cwd, basename, formatdict)
    Report(cwd, basename, formatdict, "", "", 1, AbstractString[], :text, nothing)
end


#const report = Report()

const supported_mime_types =
    [MIME"image/png",
     MIME"text/plain"]

function Base.display(doc::Report, data)
    for m in supported_mime_types
        if mimewritable(m(), data)
            display(doc, m(), data)
            break
        end
    end
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
  info("Writing to file $outname")
end


"""
`function weave(source ; doctype = :auto, plotlib="Gadfly",
        informat=:auto, out_path=:doc, fig_path = "figures", fig_ext = nothing,
        cache_path = "cache", cache=:off)`

Weave an input document to output file.

* `doctype`: :auto = set based on file extension or specify one of the supported formats.
  See `list_out_formats()`
* `plotlib`: `"PyPlot"`, `"Gadfly"` or `nothing`
* `informat`: :auto = set based on file extension or set to  `"noweb"`, `"markdown"` or  `script`
* `out_path`: Path where the output is generated. Can be: `:doc`: Path of the source document, `:pwd`: Julia working directory, `"somepath"`: output directory as a String e.g `"/home/mpastell/weaveout"` or filename as string e.g. ~/outpath/outfile.tex.
* `fig_path`: where figures will be generated, relative to out_path
* `fig_ext`: Extension for saved figures e.g. `".pdf"`, `".png"`. Default setting depends on `doctype`.
* `cache_path`: where of cached output will be saved.
* `cache`: controls caching of code: `:off` = no caching, `:all` = cache everything,
  `:user` = cache based on chunk options, `:refresh`, run all code chunks and save new cache.

**Note:** Run Weave from terminal and not using IJulia, Juno or ESS, they tend to mess with capturing output.
"""
function weave(source ; doctype = :auto, plotlib="Gadfly",
        informat=:auto, out_path=:doc, fig_path = "figures", fig_ext = nothing,
        cache_path = "cache", cache=:off)

    doc = read_doc(source, informat)
    doc = run(doc, doctype = doctype, plotlib=plotlib,
            out_path=out_path,
            fig_path = fig_path, fig_ext = fig_ext, cache_path = cache_path, cache=cache)
    formatted = format(doc)

    formatted = join(formatted, "\n")

    outname = get_outname(out_path, doc)

    open(outname, "w") do io
        write(io, formatted)
    end

    #Convert using pandoc
    if doc.doctype == "md2html"
        outname = get_outname(out_path, doc, ext = "html")
        pandoc2html(formatted, doc, outname)
    elseif doc.doctype == "md2pdf"
        outname = get_outname(out_path, doc, ext = "pdf")
        pandoc2pdf(formatted, doc, outname)
    end

    doc.cwd == pwd() && (outname = basename(outname))

    info("Report weaved to $outname")
end




function Base.display(report::Report, m::MIME"text/plain", data)
    s = reprmime(m, data)
    print("\n" * s)
    #report.cur_result *= "\n" * s
end

function weave(doc::AbstractString, doctype::AbstractString)
    weave(doc, doctype=doctype)
end

export weave, list_out_formats, tangle,
        set_chunk_defaults, get_chunk_defaults, restore_chunk_defaults

include("config.jl")
include("chunks.jl")
include("readers.jl")
include("run.jl")
include("cache.jl")
include("formatters.jl")
include("pandoc.jl")
end
