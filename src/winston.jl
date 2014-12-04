using Winston

function display(report::Report, m::MIME"image/png", data)

    chunk = report.cur_chunk
    full_name, rel_name = get_figname(report, chunk)

    docformat = formats[report.formatdict[:doctype]]

    #Add to results for term chunks and store otherwise
    if chunk[:term]
      chunk[:figure] = [rel_name]
      report.cur_result *= "\n" * report.formatdict[:codeend]
      report.cur_result *= formatfigures(chunk, docformat)
      report.cur_result *=  "\n\n" * report.formatdict[:codestart]
      chunk[:figure] = String[]
    else
      push!(report.figures, rel_name)
    end

    report.fignum += 1
    out = open(full_name, "w")
    writemime(out, m, data)
    close(out)
end
