module PGFPlotsXPlots

using ..Weave, ..PGFPlotsX

Base.showable(m::MIME"text/latex", plot::PGFPlotsX.AxisLike) = true
Base.showable(m::MIME"text/tikz", plot::PGFPlotsX.AxisLike) = true

const str_warning = "Could not add LaTeX preamble to document."

function add_standalone(format::Weave.LaTeXFormat)
    str = print_tex(String, "\\usepackage{standalone}") # Adds newline character.
    if !contains(format.tex_deps, str)
        format.tex_deps *= str
    end
    return nothing
end

function add_standalone(format::Weave.LaTeX2PDF)
    return add_standalone(format.primaryformat)
end

function add_standalone(format)
    @warn str_warning
    return nothing
end

function add_preamble(format::Weave.LaTeXFormat)
    for item in unique([PGFPlotsX.DEFAULT_PREAMBLE; PGFPlotsX.CUSTOM_PREAMBLE])
        str = print_tex(String, item) # Adds newline character.
        if !contains(format.tex_deps, str)
            format.tex_deps *= str
        end
    end
    return nothing
end

function add_preamble(format::Weave.LaTeX2PDF)
    return add_preamble(format.primaryformat)
end

function add_preamble(format)
    @warn str_warning
    return nothing
end


function Base.display(report::Weave.Report, m::MIME"text/latex", figure::PGFPlotsX.AxisLike)

    add_standalone(report.format)

    add_preamble(report.format)

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

    add_preamble(report.format)

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
