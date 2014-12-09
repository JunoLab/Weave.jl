using Winston

function Base.display(report::Report, m::MIME"image/png", data)

    chunk = report.cur_chunk
    full_name, rel_name = get_figname(report, chunk)

    docformat = formats[report.formatdict[:doctype]]

    #Add to results for term chunks and store otherwise
    if chunk[:term]
      chunk[:figure] = [rel_name]

      if report.term_state == :text
        report.cur_result *= "\n" * report.formatdict[:codeend] * "\n"
      end

      report.cur_result *= formatfigures(chunk, docformat)
      report.term_state = :fig
      chunk[:figure] = String[]
    else
      push!(report.figures, rel_name)
    end

    vector_fmts = [".pdf", ".svg"]

    #Don't use dpi for vector formats
    if chunk[:fig_ext] in vector_fmts
        savefig(data, full_name, width=chunk[:fig_width]*100, height=chunk[:fig_height]*100)
    else
        savefig(data, full_name, width=chunk[:fig_width]*chunk[:dpi], height=chunk[:fig_height]*chunk[:dpi])
    end

    report.fignum += 1
end
