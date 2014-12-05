using Gadfly

Gadfly.set_default_plot_format(:png)

#Captures figures
function Base.display(report::Report, m::MIME"image/png", p::Plot)
    chunk = report.cur_chunk

    #if chunk[:fig_ext] != ".png"
    #  chunk[:fig_ext]
    #  warn("Saving figures as .png with Gadfly")
    #end

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

    #TODO other formats
    #Can't specify dpi in Gadfly? Opened Gadfly issue #504
    w = chunk[:fig_width]inch
    h = chunk[:fig_height]inch
    format = chunk[:fig_ext]
    @show format

    #This is probably not the correct way to handle different formats, but it works.
    if format == ".png"
        draw(PNG(full_name, w, h), p)
    elseif format == ".pdf"
        draw(PDF(full_name, w, h), p)
    elseif format == ".ps"
        draw(PS(full_name, w, h), p)
    elseif format == ".svg"
        draw(SVG(full_name, w, h), p)
    elseif format == ".js.svg"
        draw(SVGJS(full_name, w, h), p)
    else:
        warn("Can't save figure. Unsupported format")
    end
end
