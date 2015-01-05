import Winston

function Base.display(report::Report, m::MIME"image/png", data)

    chunk = report.cur_chunk
    full_name, rel_name = get_figname(report, chunk)

    docformat = formats[report.formatdict[:doctype]]

    #Add to results for term chunks and store otherwise
    if chunk.options[:term]
      chunk.figures = [rel_name]

      if report.term_state == :text
        report.cur_result *= "\n" * report.formatdict[:codeend] * "\n"
      end

      report.cur_result *= formatfigures(chunk, docformat)
      report.term_state = :fig
      chunk.figures = String[]
    else
      push!(report.figures, rel_name)
    end

    vector_fmts = [".pdf", ".svg"]

    #Don't use dpi for vector formats
    if chunk.options[:fig_ext] in vector_fmts
        Winston.savefig(data, full_name, width=chunk.options[:fig_width]*100,
            height=chunk.options[:fig_height]*100)
    else
        Winston.savefig(data, full_name,
            width=chunk.options[:fig_width]*chunk.options[:dpi],
            height=chunk.options[:fig_height]*chunk.options[:dpi])
    end

    report.fignum += 1
end
