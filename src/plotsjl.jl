
using Plots

#Captures figures
function Base.display(report::Report, m::MIME"image/png", data)

    chunk = report.cur_chunk
    full_name, rel_name = get_figname(report, chunk)

    docformat = formats[report.formatdict[:doctype]]
    push!(report.figures, rel_name)

    report.fignum += 1

    w = chunk.options[:fig_width]
    h = chunk.options[:fig_height]
    format = chunk.options[:fig_ext]
    dpi = chunk.options[:dpi]
    info("Caught a plot")
    info(typeof(data))
    savefig(data, full_name)

    #This is probably not the correct way to handle different formats, but it works.
    # if format == ".png"
    #     try
    #         draw(PNG(full_name, w, h, dpi=dpi), p)
    #     catch
    #         draw(PNG(full_name, w, h), p) #Compose < 0.3.1, Gadfly < 0.3.1
    #     end
    # elseif format == ".pdf"
    #     draw(PDF(full_name, w, h), p)
    # elseif format == ".ps"
    #     draw(PS(full_name, w, h), p)
    # elseif format == ".svg"
    #     draw(SVG(full_name, w, h), p)
    # elseif format == ".js.svg"
    #     draw(SVGJS(full_name, w, h), p)
    # elseif format == ".tex"
    #     draw(PGF(full_name, w, h, true ), p)
    # else:
    #     warn("Can't save figure. Unsupported format")
    # end
end
