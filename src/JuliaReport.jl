module JuliaReport
using Compat

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
  cur_chunk::Dict{Symbol, Any}


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


function list_out_formats()
  for format = keys(formats)
      println(string(format,": ",  formats[format].description))
  end
end

#Module for report scope, idea from Judo.jl
module ReportSandBox
end


function weave(source ; doctype = "pandoc", plotlib="PyPlot", informat="noweb", fig_path = "figures", fig_ext = nothing)

    cwd, fname = splitdir(abspath(source))
    basename = splitext(fname)[1]
    formatdict = formats[doctype].formatdict
    if fig_ext == nothing
        rcParams[:chunk_defaults][:fig_ext] = formatdict[:fig_ext]
    else
        rcParams[:chunk_defaults][:fig_ext] = fig_ext
    end



    #report = Report(source, false, cwd, basename, formatdict, "", figdir)

    report.source = source
    report.cwd = cwd
    report.basename = basename
    rcParams[:chunk_defaults][:fig_path] = fig_path
    report.formatdict = formatdict


    if plotlib == nothing
        rcParams[:chunk_defaults][:fig] = false
    else
        l_plotlib = lowercase(plotlib)
        if l_plotlib == "winston"
            eval(parse("""include(Pkg.dir("JuliaReport","src","winston.jl"))"""))
            rcParams[:plotlib] = "Winston"
        elseif l_plotlib == "pyplot"
            eval(Expr(:using, :PyPlot))
            rcParams[:plotlib] = "PyPlot"
        elseif l_plotlib == "gadfly"
            eval(parse("""include(Pkg.dir("JuliaReport","src","gadfly.jl"))"""))
            rcParams[:plotlib] = "Gadfly"
        end
    end

    pushdisplay(report)
    parsed = read_document(source, informat)
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
    result = ""

    rw, wr = redirect_stdout()
    #If there is nothing to read code will hang
    println()


    try
      n = length(code_str)
      pos = 2 #The first character is extra line end
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
  i = 1
  for chunk in copy(parsed)
    if chunk[:type] == "code"
      #print(chunk["content"])
      info("Weaving chunk $(chunk[:number]) from line $(chunk[:start_line])")
      defaults = copy(rcParams[:chunk_defaults])
      options = copy(chunk[:options])
      try
        options = merge(rcParams[:chunk_defaults], options)
      catch
        options = rcParams[:chunk_defaults]
        warn("Invalid format for chunk options line: $(chunk[:start_line])")
      end

      merge!(chunk, options)
      delete!(chunk, :options)

      chunk[:eval] || (chunk[:result] = ""; continue) #Do nothing if eval is false

      report.fignum = 1
      report.cur_result = ""
      report.figures = String[]
      report.cur_chunk = chunk
      report.term_state = :text
      if haskey(report.formatdict, :out_width) && chunk[:out_width] == nothing
          chunk[:out_width] = report.formatdict[:out_width]
      end

      if chunk[:term]
        chunk[:result] = run_term(chunk[:content])
        chunk[:term_state] = report.term_state
      else
        chunk[:result] = run_block(chunk[:content])
      end
      if rcParams[:plotlib] == "PyPlot"
        chunk[:fig] && (chunk[:figure] = savefigs(chunk))
      else
        chunk[:fig] && (chunk[:figure] = copy(report.figures))
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
    end
end

function savefigs_pyplot(chunk)
    fignames = String[]
    ext = report.formatdict[:fig_ext]
    figpath = joinpath(report.cwd, chunk[:fig_path])
    isdir(figpath) || mkdir(figpath)
    chunkid = (chunk[:name] == nothing) ? chunk[:number] : chunk[:name]
    #Iterate over all open figures, save them and store names
    for fig = plt.get_fignums()
        full_name, rel_name = get_figname(report, chunk, fignum=fig)
        savefig(full_name, dpi=chunk[:dpi])
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
    figpath = joinpath(report.cwd, chunk[:fig_path])
    isdir(figpath) || mkdir(figpath)
    ext = chunk[:fig_ext]
    fignum == nothing && (fignum = report.fignum)

    chunkid = (chunk[:name] == nothing) ? chunk[:number] : chunk[:name]
    full_name = joinpath(report.cwd, chunk[:fig_path], "$(report.basename)_$(chunkid)_$(fignum)$ext")
    rel_name = "$(chunk[:fig_path])/$(report.basename)_$(chunkid)_$(fignum)$ext" #Relative path is used in output
    return full_name, rel_name
end

export weave, list_out_formats

include("config.jl")
include("readers.jl")
include("formatters.jl")
end
