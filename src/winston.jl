import Winston

function Base.display(report::Report, m::MIME"image/svg+xml", Winston.FramedPlot)

    chunk = report.cur_chunk
    full_name, rel_name = get_figname(report, chunk)

    docformat = formats[report.formatdict[:doctype]]
    push!(report.figures, rel_name)
    report.fignum += 1
    vector_fmts = [".pdf"; ".svg"]
    #Don't use dpi for vector formats
    if chunk.options[:fig_ext] in vector_fmts
        Winston.savefig(data, full_name, width=chunk.options[:fig_width]*100,
            height=chunk.options[:fig_height]*100)
    else
        Winston.savefig(data, full_name,
            width=chunk.options[:fig_width]*chunk.options[:dpi],
            height=chunk.options[:fig_height]*chunk.options[:dpi])
    end
end
