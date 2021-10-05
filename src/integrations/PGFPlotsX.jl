module PGFPlotsXPlots

using ..Weave, ..PGFPlotsX

Base.showable(m::MIME"text/latex", plot::PGFPlotsX.AxisLike) = true
Base.showable(m::MIME"text/tikz", plot::PGFPlotsX.AxisLike) = true

function Base.display(report::Weave.Report, m::MIME"text/latex", figure::PGFPlotsX.AxisLike)

    chunk = report.cur_chunk

    ext = chunk.options[:fig_ext]
    dpi = chunk.options[:dpi]

    full_name, rel_name = Weave.get_figname(report, chunk, ext = ext)

    pgfsave(full_name, figure; include_preamble = true, dpi = dpi)

    push!(report.figures, rel_name)
    report.fignum += 1

    return full_name
end

function Base.display(report::Weave.Report, m::MIME"text/tikz", figure::PGFPlotsX.AxisLike)

    chunk = report.cur_chunk

    ext = chunk.options[:fig_ext]
    dpi = chunk.options[:dpi]

    full_name, rel_name = Weave.get_figname(report, chunk, ext = ext)

    pgfsave(full_name, figure; include_preamble = false, dpi = dpi)

    push!(report.figures, rel_name)
    report.fignum += 1

    return full_name
end

end # PGFPlotsXPlots
