module GadflyPlots

using ..Weave, ..Gadfly


Gadfly.set_default_plot_format(:svg)

Base.showable(m::MIME"application/pdf", p::Gadfly.Plot) = true
Base.showable(m::MIME"application/png", p::Gadfly.Plot) = true

function Base.display(report::Weave.Report, m::MIME"application/pdf", p::Gadfly.Plot)
    display(report, MIME("image/svg+xml"), p)
end

function Base.display(report::Weave.Report, m::MIME"image/png", p::Gadfly.Plot)
    display(report, MIME("image/svg+xml"), p)
end

# Gadfly doesn't call the default display methods, this catches
# all Gadfly plots
function Base.display(report::Weave.Report, m::MIME"image/svg+xml", p::Gadfly.Plot)
    chunk = report.cur_chunk

    w = chunk.options[:fig_width] * Gadfly.inch
    h = chunk.options[:fig_height] * Gadfly.inch
    format = chunk.options[:fig_ext]
    dpi = chunk.options[:dpi]

    full_name, rel_name = Weave.get_figname(report, chunk, ext = format)

    push!(report.figures, rel_name)
    report.fignum += 1

    if format == ".svg"
        Gadfly.draw(Gadfly.SVG(full_name, w, h), p)
    elseif format == ".js.svg"
        Gadfly.draw(Gadfly.SVGJS(full_name, w, h), p)
    elseif format == ".png"
        Gadfly.draw(Gadfly.PNG(full_name, w, h, dpi = dpi), p)
    elseif format == ".pdf"
        Gadfly.draw(Gadfly.PDF(full_name, w, h), p)
    elseif format == ".ps"
        Gadfly.draw(Gadfly.PS(full_name, w, h), p)
    elseif format == ".tex"
        Gadfly.draw(Gadfly.PGF(full_name, w, h, true), p)
    else
        @warn("Can't save figure. Unsupported format, $format")
    end
end

end
