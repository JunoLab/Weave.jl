
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
        chunk.options[:fig] && (chunk.figures = savefigs(chunk, report::Report))
    else
        chunk.options[:fig] && (chunk.figures = copy(report.figures))
    end
    chunk
end

function eval_chunk(chunk::DocChunk, report::Report)
    chunk
end
