abstract type MarkdownFormat <: WeaveFormat end

# GitHub markdown
# ---------------

Base.@kwdef mutable struct GitHubMarkdown <: MarkdownFormat
    description = "GitHub markdown"
    extension = "md"
    codestart = "````julia"
    codeend = "````\n\n"
    termstart = codestart
    termend = codeend
    outputstart = "````"
    outputend = "````\n\n"
    fig_ext = ".png"
    mimetypes = ["image/png", "image/svg+xml", "image/jpg",
                "text/markdown", "text/plain"]
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    # specials
    preserve_header = true
end
register_format!("github", GitHubMarkdown())

function formatfigures(chunk, docformat::GitHubMarkdown)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    result = ""
    figstring = ""

    length(fignames) > 0 || (return "")

    if !isnothing(caption)
        result *= "![$caption]($(fignames[1]))\n"
        for fig in fignames[2:end]
            result *= "![]($fig)\n"
            println("Warning, only the first figure gets a caption\n")
        end
    else
        for fig in fignames
            result *= "![]($fig)\n"
        end
    end
    return result
end

# Hugo markdown
# -------------

Base.@kwdef mutable struct Hugo <: MarkdownFormat
    description = "Hugo markdown (using shortcodes)"
    extension = "md"
    codestart = "````julia"
    codeend = "````\n\n"
    termstart = codestart
    termend = codeend
    outputstart = "````"
    outputend = "````\n\n"
    mimetypes = default_mime_types
    fig_ext = ".png"
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    # specials
    preserve_header = true
    uglyURLs = false # if `false`, prepend figure path by `..`
end
register_format!("hugo", Hugo())

function formatfigures(chunk, docformat::Hugo)
    relpath = docformat.uglyURLs ? "" : ".."
    mapreduce(*, enumerate(chunk.figures), init = "") do (index, fig)
        if index > 1
            @warn("Only the first figure gets a caption.")
            title_spec = ""
        else
            caption = chunk.options[:fig_cap]
            title_spec = isnothing(caption) ? "" : "title=\"$(caption)\" "
        end
        "{{< figure src=\"$(joinpath(relpath, fig))\" $(title_spec) >}}"
    end
end

# multi language markdown
# -----------------------

Base.@kwdef mutable struct MultiMarkdown <: MarkdownFormat
    description = "MultiMarkdown"
    extension = "md"
    codestart = "````julia"
    codeend = "````\n\n"
    termstart = codestart
    termend = codeend
    outputstart = "````"
    outputend = "````\n\n"
    mimetypes = default_mime_types
    fig_ext = ".png"
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    # specials
    preserve_header = true
end
register_format!("multimarkdown", MultiMarkdown())

function formatfigures(chunk, docformat::MultiMarkdown)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    result = ""
    figstring = ""

    if chunk.options[:out_width] == nothing
        width = ""
    else
        width = "width=$(chunk.options[:out_width])"
    end

    length(fignames) > 0 || (return "")

    if !isnothing(caption)
        result *= "![$caption][$(fignames[1])]\n\n"
        result *= "[$(fignames[1])]: $(fignames[1]) $width\n"
        for fig in fignames[2:end]
            result *= "![][$fig]\n\n"
            result *= "[$fig]: $fig $width\n"
            println("Warning, only the first figure gets a caption\n")
        end
    else
        for fig in fignames
            result *= "![][$fig]\n\n"
            result *= "[$fig]: $fig $width\n"
        end
    end
    return result
end

# pandoc
# ------

abstract type PandocFormat <: MarkdownFormat end

function formatfigures(chunk, docformat::PandocFormat)
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
    description = "Pandoc markdown"
    extension = "md"
    codestart = "~~~~{.julia}"
    codeend = "~~~~~~~~~~~~~\n\n"
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
end
register_format!("pandoc", Pandoc())

Base.@kwdef mutable struct Pandoc2PDF <: PandocFormat
    description = "Pandoc markdown to PDF"
    extension = "md"
    codestart = "~~~~{.julia}"
    codeend = "~~~~~~~~~~~~~\n\n"
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
    header_template = normpath(TEMPLATE_DIR, "pandoc2pdf_header.txt")
    pandoc_options = String[]
end
register_format!("pandoc2pdf", Pandoc2PDF())

function set_format_options!(docformat::Pandoc2PDF; pandoc_options = String[], _kwargs...)
    docformat.pandoc_options = pandoc_options
end
