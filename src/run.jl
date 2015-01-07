function run(doc::WeaveDoc; doctype = "pandoc", plotlib="Gadfly", informat="noweb", out_path=:doc, fig_path = "figures", fig_ext = nothing)
    doc.cwd = get_cwd(doc, out_path)
    doc.format = formats[doctype]
    set_rc_params(doc.format.formatdict, fig_path, fig_ext)

    #Clear sandbox for each document
    #Raises a warning, couldn't find a "cleaner"
    #way to do it.
    eval(parse("module ReportSandBox\nend"))

    init_plotting(plotlib)
    report = Report(doc.cwd, doc.basename, doc.format.formatdict)
    pushdisplay(report)

    executed = Any[]
    for chunk in copy(doc.chunks)
        result_chunk = eval_chunk(chunk, report::Report)
        push!(executed, result_chunk)
    end
    popdisplay(report)

    doc.chunks = executed
    return doc
end

function run_block(code_str, report::Report)
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

function run_term(code_str, report::Report)
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

function eval_chunk(chunk::CodeChunk, report::Report)
    info("Weaving chunk $(chunk.number) from line $(chunk.start_line)")
    defaults = copy(rcParams[:chunk_defaults])
    options = copy(chunk.options)
    try
        options = merge(rcParams[:chunk_defaults], options)
    catch
        options = rcParams[:chunk_defaults]
        warn("Invalid format for chunk options line: $(chunk.start_line)")
    end

    merge!(chunk.options, options)
    #delete!(chunk.options, :options)
    #@show chunk.options

    if !chunk.options[:eval]
        chunk.output = ""
        chunk.options[:fig] = false
        return chunk
    end

    report.fignum = 1
    report.cur_result = ""
    report.figures = String[]
    report.cur_chunk = chunk
    report.term_state = :text
    if haskey(report.formatdict, :out_width) && chunk.options[:out_width] == nothing
        chunk.options[:out_width] = report.formatdict[:out_width]
    end

    if chunk.options[:term]
        chunk.output = run_term(chunk.content, report::Report)
        chunk.options[:term_state] = report.term_state
    else
        chunk.output = run_block(chunk.content, report::Report)
    end

    if rcParams[:plotlib] == "PyPlot"
        chunk.options[:fig] && (chunk.figures = savefigs_pyplot(chunk, report::Report))
    else
        chunk.options[:fig] && (chunk.figures = copy(report.figures))
    end
    chunk
end

function eval_chunk(chunk::DocChunk, report::Report)
    chunk
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


function init_plotting(plotlib)
    if plotlib == nothing
        rcParams[:chunk_defaults][:fig] = false
    else
        l_plotlib = lowercase(plotlib)
        rcParams[:chunk_defaults][:fig] = true

        if l_plotlib == "winston"
            eval(parse("""include(Pkg.dir("Weave","src","winston.jl"))"""))
            rcParams[:plotlib] = "Winston"
        elseif l_plotlib == "pyplot"
            eval(parse("""include(Pkg.dir("Weave","src","pyplot.jl"))"""))
            rcParams[:plotlib] = "PyPlot"
        elseif l_plotlib == "gadfly"
            eval(parse("""include(Pkg.dir("Weave","src","gadfly.jl"))"""))
            rcParams[:plotlib] = "Gadfly"
        end
    end
    return nothing
end

function get_cwd(doc::WeaveDoc, out_path)
    #Set the output directory
    if out_path == :doc
        cwd = doc.path
    elseif out_path == :pwd
        cwd = pwd()
    else
        cwd = out_path
    end
    return cwd
end

function set_rc_params(formatdict, fig_path, fig_ext)
    if fig_ext == nothing
        rcParams[:chunk_defaults][:fig_ext] = formatdict[:fig_ext]
    else
        rcParams[:chunk_defaults][:fig_ext] = fig_ext
    end
    rcParams[:chunk_defaults][:fig_path] = fig_path
    return nothing
end
