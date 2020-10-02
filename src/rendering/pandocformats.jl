abstract type PandocFormat <: WeaveFormat end

function render_figures(docformat::PandocFormat, chunk)
    fignames = chunk.figures
    length(fignames) > 0 || (return "")

    caption = chunk.options[:fig_cap]
    label = get(chunk.options, :label, nothing)
    result = ""
    figstring = ""
    attribs = ""
    width = chunk.options[:out_width]
    height = chunk.options[:out_height]

    # Build figure attibutes
    attribs = String[]
    isnothing(width) || push!(attribs, "width=$width")
    isnothing(height) || push!(attribs, "height=$height")
    isnothing(label) || push!(attribs, "#fig:$label")
    attribs = isempty(attribs) ? "" : "{" * join(attribs, " ") * "}"

    if !isnothing(caption)
        result *= "![$caption]($(fignames[1]))$attribs\n"
        for fig in fignames[2:end]
            result *= "![]($fig)$attribs\n"
            println("Warning, only the first figure gets a caption\n")
        end
    else
        for fig in fignames
            result *= "![]($fig)$attribs\\ \n\n"
        end
    end
    return result
end

Base.@kwdef mutable struct Pandoc <: PandocFormat
    description = "Pandoc Markdown"
    extension = "md"
    codestart = "~~~~{.julia}"
    codeend = "~~~~~~~~~~~~~\n"
    termstart = codestart
    termend = codeend
    outputstart = "~~~~"
    outputend = "~~~~\n\n"
    # Prefer png figures for markdown conversion, svg doesn't work with latex
    mimetypes = ["image/png", "image/jpg", "image/svg+xml", "text/markdown", "text/plain"]
    fig_ext = ".png"
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    # specials
    preserve_header = true
end
register_format!("pandoc", Pandoc())

const DEFAULT_PANDOC_OPTIONS = String[]

Base.@kwdef mutable struct Pandoc2PDF <: PandocFormat
    description = "PDF via intermediate Pandoc Markdown"
    extension = "md"
    codestart = "~~~~{.julia}"
    codeend = "~~~~~~~~~~~~~\n"
    termstart = codestart
    termend = codeend
    outputstart = "~~~~"
    outputend = "~~~~\n\n"
    # Prefer png figures for markdown conversion, svg doesn't work with latex
    mimetypes = ["image/png", "image/jpg", "image/svg+xml", "text/markdown", "text/plain"]
    fig_ext = ".png"
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    # specials
    preserve_header = true
    header_template = normpath(TEMPLATE_DIR, "pandoc2pdf_header.txt")
    pandoc_options = DEFAULT_PANDOC_OPTIONS
end
register_format!("pandoc2pdf", Pandoc2PDF())

function set_format_options!(docformat::Pandoc2PDF; pandoc_options = DEFAULT_PANDOC_OPTIONS, _kwargs...)
    docformat.pandoc_options = pandoc_options
end
