module Weave
using Compat
using Docile

@docstrings(manual = ["../doc/manual.md"])

#Contains report global properties
type Report <: Display
  cwd::String
  basename::String
  formatdict::Dict{Symbol,Any}
  pending_code::String
  cur_result::String
  fignum::Int
  figures::Array{String}
  term_state::Symbol
  cur_chunk

  function Report(cwd, basename, formatdict)
        new(cwd, basename, formatdict, "", "", 1, String[], :text, nothing)
  end

end

#const report = Report()

const supported_mime_types =
    [MIME"image/png",
     MIME"text/plain"]

function Base.display(doc::Report, data)
    for m in supported_mime_types
        if mimewritable(m(), data)
            display(doc, m(), data)
            brea
        end
    end
end

@doc "List supported output formats" ->
function list_out_formats()
  for format = keys(formats)
      println(string(format,": ",  formats[format].description))
  end
end

#module ReportSandBox
#end

@doc md"""
Tangle source code from input document to .jl file.

**parameters:**
```julia
tangle(source ; out_path=:doc, informat="noweb")
```

* `informat`: `"noweb"` of `"markdown"`
* `out_path`: Path where the output is generated. Can be: `:doc`: Path of the source document, `:pwd`: Julia working directory,
`"somepath"`: Path as a string e.g `"/home/mpastell/weaveout"`
"""->
function tangle(source ; out_path=:doc, informat="noweb")
    doc = read_doc(source, informat)
    cwd = get_cwd(doc, out_path)

    outname = "$(cwd)/$(doc.basename).jl"
    open(outname, "w") do io
        for chunk in doc.chunks
            if typeof(chunk) == CodeChunk
                write(io, chunk.content*"\n")
            end
        end
    end

    info("Writing to file $(basename).jl")
end

@doc md"""
Weave an input document to output file.

**parameters:**
```julia
weave(source ; doctype = "pandoc", plotlib="Gadfly",
    informat="noweb", out_path=:doc, fig_path = "figures", fig_ext = nothing)
```

* `doctype`: see `list_out_formats()`
* `plotlib`: `"PyPlot"`, `"Gadfly"`, or `"Winston"`
* `informat`: `"noweb"` of `"markdown"`
* `out_path`: Path where the output is generated. Can be: `:doc`: Path of the source document, `:pwd`: Julia working directory,
    `"somepath"`: Path as a string e.g `"/home/mpastell/weaveout"`
* `fig_path`: where figures will be generated, relative to out_path
* `fig_ext`: Extension for saved figures e.g. `".pdf"`, `".png"`. Default setting depends on `doctype`.

**Note:** Run Weave from terminal and not using IJulia, Juno or ESS, they tend to mess with capturing output.
""" ->
function weave(source ; doctype = "pandoc", plotlib="Gadfly",
    informat="noweb", out_path=:doc, fig_path = "figures", fig_ext = nothing)

    doc = read_doc(source, informat) #Reader toimii, muuten kesken...
    doc = run(doc, doctype = doctype, plotlib=plotlib,
            informat = informat, out_path=out_path, fig_path = fig_path, fig_ext = fig_ext)
    formatted = format(doc)

    outname = "$(doc.cwd)/$(doc.basename).$(doc.format.formatdict[:extension])"
    open(outname, "w") do io
        write(io, join(formatted, "\n"))
    end

    info("Report weaved to $(doc.basename).$(doc.format.formatdict[:extension])")
end



function savefigs(chunk, report::Report)
    l_plotlib = lowercase(rcParams[:plotlib])
    if l_plotlib == "pyplot"
      return savefigs_pyplot(chunk, report::Report)
    end
end

function savefigs_pyplot(chunk, report::Report)
    fignames = String[]
    ext = report.formatdict[:fig_ext]
    figpath = joinpath(report.cwd, chunk.options[:fig_path])
    isdir(figpath) || mkdir(figpath)
    chunkid = (chunk.options[:name] == nothing) ? chunk.number : chunk.options[:name]
    #Iterate over all open figures, save them and store names
    for fig = plt.get_fignums()
        full_name, rel_name = get_figname(report, chunk, fignum=fig)
        savefig(full_name, dpi=chunk.options[:dpi])
        push!(fignames, rel_name)
        plt.draw()
        plt.close()
    end
    return fignames
end


function Base.display(report::Report, m::MIME"text/plain", data)
  if report.term_state == :fig #Catch Winston plot command output
    report.cur_result *= "\n" * report.formatdict[:codestart] * "\n"
  end

  s = reprmime(m, data)
  haskey(report.formatdict, :indent) && (s = indent(s, report.formatdict[:indent]))

  report.cur_result *= s * "\n"

  if report.term_state == :fig #Catch Winston plot command output
    report.cur_result *= "\n" * report.formatdict[:codeend] * "\n"
  end
end

function get_figname(report::Report, chunk; fignum = nothing)
    figpath = joinpath(report.cwd, chunk.options[:fig_path])
    isdir(figpath) || mkdir(figpath)
    ext = chunk.options[:fig_ext]
    fignum == nothing && (fignum = report.fignum)

    chunkid = (chunk.options[:name] == nothing) ? chunk.number : chunk.options[:name]
    full_name = joinpath(report.cwd, chunk.options[:fig_path],
                                "$(report.basename)_$(chunkid)_$(fignum)$ext")
    rel_name = "$(chunk.options[:fig_path])/$(report.basename)_$(chunkid)_$(fignum)$ext" #Relative path is used in output
    return full_name, rel_name
end

export weave, list_out_formats, tangle

include("chunks.jl")
include("run.jl")
include("config.jl")
include("readers.jl")
include("formatters.jl")
end
