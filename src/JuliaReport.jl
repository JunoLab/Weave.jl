module JuliaReport
using Compat
import Base: display

#Contains report global properties
type Report <: Display
  source::String
  documentationmode::Bool
  cwd::String
  basename::String
  formatdict
  pending_code::String
  figdir::String
  executed::Array
  cur_result::String
  fignum::Int
  figures::Array
  cur_chunk::Dict

  function Report()
        new("", false, "", "",  Any[], "", "", {}, "", 1, {},  @compat Dict{Symbol, Any}())
  end

end

const report = Report()

const supported_mime_types =
    {
      MIME"image/png",
      MIME"text/plain" }

function display(doc::Report, data)
    for m in supported_mime_types
        if mimewritable(m(), data)
            display(doc, m(), data)
            brea
        end
    end
end


#function listformats()
  #pweave.listformats() TODO: implement
#end

#Module for report scope, idea from Judo.jl
module ReportSandBox
end


function weave(source ; doctype = "pandoc", plotlib="PyPlot", informat="noweb", figdir = "figures", figformat = nothing)

    cwd, fname = splitdir(abspath(source))
    basename = splitext(fname)[1]
    formatdict = formats[doctype].formatdict
    figformat == nothing || (formatdict[:figfmt] = figformat)
    #report = Report(source, false, cwd, basename, formatdict, "", figdir)

    report.source = source
    report.cwd = cwd
    report.basename = basename
    report.figdir = figdir
    report.formatdict = formatdict
    pushdisplay(report)

    if plotlib == nothing
        rcParams[:chunk][:defaultoptions][:fig] = false
    else
        l_plotlib = lowercase(plotlib)
        if l_plotlib == "winston"
            eval(Expr(:using, :Winston))
            rcParams[:plotlib] = "Winston"
        elseif l_plotlib == "pyplot"
            eval(Expr(:using, :PyPlot))
            rcParams[:plotlib] = "PyPlot"
        elseif l_plotlib == "gadfly"
            println("GadFly")
            eval(parse("""include(Pkg.dir("JuliaReport","src","gadfly.jl"))"""))
            rcParams[:plotlib] = "Gadfly"
            #pushdisplay(doc)
        end
    end

    parsed = read_noweb(source)
    executed = run(parsed)
    popdisplay(report)
    formatted = format(executed, doctype)
    outname = "$(report.cwd)/$(report.basename).$(formatdict[:extension])"
    @show outname
    open(outname, "w") do io
        write(io, join(formatted, "\n"))
    end

    info("Report weaved to $(report.basename).$(formatdict[:extension])")

end


function run_block(code_str)
    oldSTDOUT = STDOUT
    #If there is nothing to read code will hang
    println()
    rw, wr = redirect_stdout()
    #include_string(code_str)

    n = length(code_str)
    pos = 2 #The first character is extra line end
    while pos < n
        oldpos = pos
        code, pos = parse(code_str, pos)
        s = eval(ReportSandBox, code)
        s != nothing && display(s)
    end

    redirect_stdout(oldSTDOUT)
    close(wr)
    result = readall(rw)
    close(rw)
    return string("\n", result)
end

function run_term(code_str)

    #Emulate terminal
    n = length(code_str)
    pos = 2 #The first character is extra line end
    while pos < n
        oldpos = pos
        code, pos = parse(code_str, pos)

	      prompts = string("\n\njulia> ", rstrip(code_str[oldpos:(pos-1)]), "\n")
	      report.cur_result *= prompts

        s = eval(ReportSandBox, code)
        s != nothing && display(s)
    end

    return string(report.cur_result)
end


function run(parsed)
  i = 1
  for chunk in copy(parsed)
    if chunk[:type] == "code"
      #print(chunk["content"])
      info("Weaving chunk $(chunk[:number]) from line $(chunk[:start_line])")
      defaults = copy(rcParams[:chunk][:defaultoptions])
      options = copy(chunk[:options])
      try
        options = merge(rcParams[:chunk][:defaultoptions], options)
      catch
        options = rcParams[:chunk][:defaultoptions]
        warn("Invalid format for chunk options line: $(chunk[:start_line])")
      end

      merge!(chunk, options)
      delete!(chunk, :options)

      chunk[:evaluate] || (chunk[:result] = ""; continue) #Do nothing if eval is false

      report.fignum = 1
      report.cur_result = ""
      report.figures = String[]
      report.cur_chunk = chunk

      if chunk[:term]
        chunk[:result] = run_term(chunk[:content])
      else
        chunk[:result] = run_block(chunk[:content])
      end
      if rcParams[:plotlib] == "Gadfly"
        chunk[:fig] && (chunk[:figure] = copy(report.figures))
      else
        chunk[:fig] && (chunk[:figure] = savefigs(chunk))
      end
    end
    parsed[i] = copy(chunk)
    i += 1
  end
  parsed
end

function savefigs(chunk)
    l_plotlib = lowercase(rcParams[:plotlib])
    if l_plotlib == "pyplot"
      return savefigs_pyplot(chunk)
    elseif l_plotlib == "winston"
      return savefigs_winston(chunk)
    elseif l_plotlib == "gadfly"
      return String[]
    end
end

function savefigs_pyplot(chunk)
    fignames = String[]
    ext = report.formatdict[:figfmt]
    figpath = joinpath(report.cwd, report.figdir)
    isdir(figpath) || mkdir(figpath)
    chunkid = (chunk[:name] == nothing) ? chunk[:number] : chunk[:name]
    #Iterate over all open figures, save them and store names
    for fig = plt.get_fignums()
        full_name = joinpath(report.cwd, report.figdir, "$(report.basename)_$(chunkid)_$fig$ext")
        rel_name = "$(report.figdir)/$(report.basename)_$(chunkid)_$fig$ext" #Relative path is used in output
        savefig(full_name)
        push!(fignames, rel_name)
        plt.draw()
        plt.close()
    end
    return fignames
end

#This currently only works if there is only one figure/chunk
#Doesn"t work with FramedPlots
#Doesn"t work with Julia 0.4
function savefigs_winston(chunk)
    fignames = String[]
    ext = report.formatdict[:figfmt]
    figpath = joinpath(report.cwd, report.figdir)
    isdir(figpath) || mkdir(figpath)

    chunkid = chunk[:name] == nothing ? chunk[:number] : chunk[:name]

    #println(Winston._display.figs)
    #println(Winston._display.fig_order)

    #Iterate over all open figures, save them and store names
    for fig = copy(Winston._display.fig_order)
        full_name = joinpath(report.cwd, report.figdir, "$(report.basename)_$(chunkid)_$fig$ext")
        rel_name = "$(report.figdir)/$(report.basename)_$(chunkid)_$fig$ext" #Relative path is used in output
        #@show rel_name
        #figure(fig) #Calling figure clears the canvas!
        #savefig(Winston._display.figs[gcf()].plot, full_name) #Produces empty figures
        savefig(full_name)
        closefig()
        push!(fignames, rel_name)
    end
    return fignames
end



function display(report::Report, m::MIME"text/plain", data)
  s = reprmime(m, data)
  report.cur_result *= s
  push!(report.executed, s)
end



export weave

include("config.jl")
include("readers.jl")
include("formatters.jl")
end


