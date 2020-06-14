abstract type SecondaryFormat <: WeaveFormat end
abstract type PDF <: SecondaryFormat end

function Base.getproperty(sf::SecondaryFormat, s::Symbol)
    hasfield(typeof(sf), s) && return getfield(sf, s)
    return getproperty(sf.primaryformat, s)
end
function Base.setproperty!(sf::SecondaryFormat, s::Symbol, v)
    if hasfield(typeof(sf), s)
        setfield!(sf, s, v)
    else
        setproperty!(sf.primaryformat, s, v)
    end
end
function Base.hasproperty(sf::SecondaryFormat, s::Symbol)
    hasfield(typeof(sf), s) || hasfield(typeof(sf.primaryformat), s)
end

format_chunk(chunk::DocChunk, docformat::SecondaryFormat) =
    format_chunk(chunk, docformat.primaryformat)

formatfigures(chunk, sf::SecondaryFormat) =
    formatfigures(chunk, sf.primaryformat)

format_code(code, sf::SecondaryFormat) =
    format_code(code, sf.primaryformat)

format_termchunk(chunk, sf::SecondaryFormat) =
    format_termchunk(chunk, sf.primaryformat)

format_output(result, sf::SecondaryFormat) =
    format_output(result, sf.primaryformat)

render_doc(docformat::SecondaryFormat, body, doc) =
    render_doc(docformat.primaryformat, body, doc)


postprocessing(doc, out_path) = postprocessing(doc.format, doc, out_path)
postprocessing(::WeaveFormat, doc, out_path) = out_path

postprocessing(docformat::SecondaryFormat, doc, out_path) =
    postprocessing(docformat, docformat.primaryformat, doc, out_path)


function set_rendering_options!(sf::SecondaryFormat; kwargs...)
    for (key, val) in pairs(kwargs)
        if hasfield(typeof(sf), key)
            setproperty!(sf, key, val)
        end
    end
    set_rendering_options!(sf.primaryformat; kwargs...)
end

Base.@kwdef mutable struct LatexPDF <: PDF
    primaryformat
    latex_cmd = "xelatex"
end

function postprocessing(sf::LatexPDF, _, doc, out_path)
    run_latex(doc, out_path, sf.latex_cmd)
    out_path = get_out_path(doc, out_path, "pdf")
end

Base.@kwdef mutable struct PandocPDF <: PDF
    primaryformat
    options
end

function postprocessing(sf::PandocPDF, df, doc, out_path)
    intermediate = out_path
    out_path = get_out_path(doc, out_path, "pdf")
    pandoc2pdf(read(intermediate, String), doc, out_path, sf.options)
    rm(intermediate)
    out_path
end

mutable struct PandocHTML <: SecondaryFormat
    primaryformat
    options
end

function postprocessing(sf::PandocHTML, df, doc)
    intermediate = out_path
    out_path = get_out_path(doc, out_path, "html")
    pandoc2html(read(intermediate, String), doc, sf.highlight_theme, out_path, sf.options)
    rm(intermediate)
    out_path
end
