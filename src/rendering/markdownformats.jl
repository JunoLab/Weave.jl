abstract type MarkdownFormat <: WeaveFormat end
# markdown
# --------

Base.@kwdef mutable struct GitHubMarkdown <: MarkdownFormat
    description = "GitHub markdown"
    codestart = "````julia"
    codeend = "````\n\n"
    outputstart = "````"
    outputend = "````\n\n"
    fig_ext = ".png"
    extension = "md"
    mimetypes = ["image/png", "image/svg+xml", "image/jpg",
                "text/markdown", "text/plain"]
    keep_unicode = false
    termstart = codestart
    termend = codeend
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    highlight_theme = nothing
    #this could be removed
    template = nothing
end
register_format!("github", GitHubMarkdown())

Base.@kwdef mutable struct Hugo <: MarkdownFormat
    description = "Hugo markdown (using shortcodes)"
    codestart = "````julia"
    codeend = "````\n\n"
    outputstart = "````"
    outputend = "````\n\n"
    fig_ext = ".png"
    extension = "md"
    uglyURLs = false # if `false`, prepend figure path by `..`
    keep_unicode = false
    mimetypes = default_mime_types
    termstart = codestart
    termend = codeend
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    highlight_theme = nothing
    #this could be removed
    template = nothing
end
register_format!("hugo", Hugo())

Base.@kwdef mutable struct MultiMarkdown <: MarkdownFormat
    description = "MultiMarkdown"
    codestart = "````julia"
    codeend = "````\n\n"
    outputstart = "````"
    outputend = "````\n\n"
    fig_ext = ".png"
    extension = "md"
    keep_unicode = false
    termstart = codestart
    termend = codeend
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    highlight_theme = nothing
    #this could be removed
    template = nothing
    mimetypes = default_mime_types
end
register_format!("multimarkdown", MultiMarkdown())


# pandoc
# ------

Base.@kwdef mutable struct Pandoc <: MarkdownFormat
    description = "Pandoc markdown"
    codestart = "~~~~{.julia}"
    codeend = "~~~~~~~~~~~~~\n\n"
    outputstart = "~~~~"
    outputend = "~~~~\n\n"
    fig_ext = ".png"
    extension = "md"
    # Prefer png figures for markdown conversion, svg doesn't work with latex
    mimetypes = ["image/png", "image/jpg", "image/svg+xml",
                "text/markdown", "text/plain"]
    keep_unicode = false
    termstart = codestart
    termend = codeend
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    highlight_theme = nothing
    template = nothing
end
register_format!("pandoc", Pandoc())
register_format!("pandoc2pdf", Pandoc())


function formatfigures(chunk, docformat::GitHubMarkdown)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    result = ""
    figstring = ""

    length(fignames) > 0 || (return "")

    if caption != nothing
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

function formatfigures(chunk, docformat::Hugo)
    relpath = docformat.uglyURLs ? "" : ".."
    mapreduce(*, enumerate(chunk.figures), init = "") do (index, fig)
        if index > 1
            @warn("Only the first figure gets a caption.")
            title_spec = ""
        else
            caption = chunk.options[:fig_cap]
            title_spec = caption == nothing ? "" : "title=\"$(caption)\" "
        end
        "{{< figure src=\"$(joinpath(relpath, fig))\" $(title_spec) >}}"
    end
end

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

    if caption != nothing
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
