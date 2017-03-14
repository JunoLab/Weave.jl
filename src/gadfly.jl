import Gadfly

Gadfly.set_default_plot_format(:svg)

#Gadfly doesn't call the default display methods, this catches
#all Gadfly plots
function Base.display(report::Report, m::MIME"image/svg+xml", p::Gadfly.Plot)

    chunk = report.cur_chunk
    full_name, rel_name = get_figname(report, chunk)

    docformat = formats[report.formatdict[:doctype]]
    push!(report.figures, rel_name)

    report.fignum += 1

    w = chunk.options[:fig_width]Gadfly.inch
    h = chunk.options[:fig_height]Gadfly.inch
    format = chunk.options[:fig_ext]
    dpi = chunk.options[:dpi]

    #This is probably not the correct way to handle different formats, but it works.
    if format == ".png"
        try
            Gadfly.draw(Gadfly.PNG(full_name, w, h, dpi=dpi), p)
        catch
            Gadfly.draw(Gadfly.PNG(full_name, w, h), p) #Compose < 0.3.1, Gadfly < 0.3.1
        end
    elseif format == ".pdf"
        Gadfly.draw(Gadfly.PDF(full_name, w, h), p)
    elseif format == ".ps"
        Gadfly.draw(Gadfly.PS(full_name, w, h), p)
    elseif format == ".svg"
        Gadfly.draw(Gadfly.SVG(full_name, w, h), p)
    elseif format == ".js.svg"
        Gadfly.draw(Gadfly.SVGJS(full_name, w, h), p)
    elseif format == ".tex"
        Gadfly.draw(Gadfly.PGF(full_name, w, h, true ), p)
    else
        warn("Can't save figure. Unsupported format")
    end
end
