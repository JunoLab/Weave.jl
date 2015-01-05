module Weave
using Compat
using Docile

@docstrings(manual = ["../doc/manual.md"])

#Contains report global properties
type Report <: Display
  source::String
  documentationmode::Bool
  cwd::String
  basename::String
  formatdict
  pending_code::String
  cur_result::String
  fignum::Int
  figures::Array
  term_state::Symbol
  cur_chunk


  function Report()
        new("", false, "", "",  Any[], "", "", 1, Any[], :text, @compat Dict{Symbol, Any}() )
  end

end

const report = Report()

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
    cwd, fname = splitdir(abspath(source))
    basename = splitext(fname)[1]

    #Set the output directory
    if out_path == :doc
        cwd = cwd
    elseif out_path == :pwd
        cwd = pwd()
    else
        cwd = out_path
    end


    outname = "$(cwd)/$(basename).jl"
    open(outname, "w") do io
        for chunk in read_document(source, informat)
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
function weave(source ; doctype = "pandoc", plotlib="Gadfly", informat="noweb", out_path=:doc, fig_path = "figures", fig_ext = nothing)

    cwd, fname = splitdir(abspath(source))
    basename = splitext(fname)[1]
    formatdict = formats[doctype].formatdict
    if fig_ext == nothing
        rcParams[:chunk_defaults][:fig_ext] = formatdict[:fig_ext]
    else
        rcParams[:chunk_defaults][:fig_ext] = fig_ext
    end

    #Set the output directory
    if out_path == :doc
        report.cwd = cwd
    elseif out_path == :pwd
        report.cwd = pwd()
    else
        report.cwd = out_path
    end



    report.source = source
    report.basename = basename
    rcParams[:chunk_defaults][:fig_path] = fig_path
    report.formatdict = formatdict


    if plotlib == nothing
        rcParams[:chunk_defaults][:fig] = false
    else
        l_plotlib = lowercase(plotlib)
        rcParams[:chunk_defaults][:fig] = true
        if l_plotlib == "winston"
            eval(parse("""include(Pkg.dir("Weave","src","winston.jl"))"""))
            rcParams[:plotlib] = "Winston"
        elseif l_plotlib == "pyplot"
            eval(Expr(:using, :PyPlot))
            rcParams[:plotlib] = "PyPlot"
        elseif l_plotlib == "gadfly"
            eval(parse("""include(Pkg.dir("Weave","src","gadfly.jl"))"""))
            rcParams[:plotlib] = "Gadfly"
        end
    end

    pushdisplay(report)
    parsed = read_document(source, informat)
    executed = run(parsed)
    popdisplay(report)
    formatted = format(executed, doctype)
    outname = "$(report.cwd)/$(report.basename).$(formatdict[:extension])"
    open(outname, "w") do io
        write(io, join(formatted, "\n"))
    end

    info("Report weaved to $(report.basename).$(formatdict[:extension])")

end





function run_block(code_str)
    oldSTDOUT = STDOUT
    result = ""

    rw, wr = redirect_stdout()
    #If there is nothing to read code will hang
    println()

    try
      n = length(code_str)
      pos = 1 #The first character is extra line end
      while pos < n
          oldpos = pos
          code, pos = parse(code_str, pos)
          s = eval(ReportSandBox, code)
          if rcParams[:plotlib] == "Gadfly"
              s != nothing && display(s)
          end
      end
    finally

      redirect_stdout(oldSTDOUT)
      close(wr)
      result = readall(rw)
      close(rw)
    end

    return string("\n", result)
end

function run_term(code_str)
    prompt = "\njulia> "
    codestart = "\n\n"*report.formatdict[:codestart]

    if haskey(report.formatdict, :indent)
        prompt = indent(prompt, report.formatdict[:indent])
    end

    #Emulate terminal
    n = length(code_str)
    pos = 2 #The first character is extra line end
    while pos < n
        oldpos = pos
        code, pos = parse(code_str, pos)

        report.term_state == :fig && (report.cur_result*= codestart)
	    prompts = string(prompt, rstrip(code_str[oldpos:(pos-1)]), "\n")
	    report.cur_result *= prompts
        report.term_state = :text
        s = eval(ReportSandBox, code)
        s != nothing && display(s)
    end

    return string(report.cur_result)
end


function run(parsed)
    #Clear sandbox for each document
    #Raises a warning, couldn't find a "cleaner"
    #way to do it.
    eval(parse("module ReportSandBox\nend"))
    executed = Any[]
    for chunk in copy(parsed)
        result_chunk = eval_chunk(chunk)
        push!(executed, result_chunk)
    end
    executed
end

function savefigs(chunk)
    l_plotlib = lowercase(rcParams[:plotlib])
    if l_plotlib == "pyplot"
      return savefigs_pyplot(chunk)
    end
end

function savefigs_pyplot(chunk)
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
