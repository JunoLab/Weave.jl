using Winston

function Base.display(report::Report, m::MIME"image/png", data)

    chunk = report.cur_chunk
    full_name, rel_name = get_figname(report, chunk)

    docformat = formats[report.formatdict[:doctype]]

    #Add to results for term chunks and store otherwise
    if chunk[:term]
      chunk[:figure] = [rel_name]

      if report.term_state == :text
        report.cur_result *= "\n" * report.formatdict[:codeend]
      end

      report.cur_result *= formatfigures(chunk, docformat)
      report.term_state = :fig
      chunk[:figure] = String[]
    else
      push!(report.figures, rel_name)
    end

    #TODO get width and height from chunk options, after implementing Knitr compatible options
    savefig(data, full_name, width=chunk[:fig_width]*chunk[:dpi], height=chunk[:fig_height]*chunk[:dpi])
    report.fignum += 1
end
