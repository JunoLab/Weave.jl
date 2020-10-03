# GitHub markdown
# ---------------

Base.@kwdef mutable struct GitHubMarkdown <: WeaveFormat
    description = "GitHub Markdown"
    extension = "md"
    codestart = "```julia"
    codeend = "```\n"
    termstart = codestart
    termend = codeend
    outputstart = "```"
    outputend = "```\n\n"
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

function render_figures(docformat::GitHubMarkdown, chunk)
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

Base.@kwdef mutable struct Hugo <: WeaveFormat
    description = "Hugo Markdown (using shortcodes)"
    extension = "md"
    codestart = "```julia"
    codeend = "```\n"
    termstart = codestart
    termend = codeend
    outputstart = "```"
    outputend = "```\n\n"
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

function render_figures(docformat::Hugo, chunk)
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

Base.@kwdef mutable struct MultiMarkdown <: WeaveFormat
    description = "MultiMarkdown"
    extension = "md"
    codestart = "```julia"
    codeend = "```\n"
    termstart = codestart
    termend = codeend
    outputstart = "```"
    outputend = "```\n\n"
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

function render_figures(docformat::MultiMarkdown, chunk)
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

# Rest
# ----

Base.@kwdef mutable struct Rest <: WeaveFormat
    description = "reStructuredText and Sphinx"
    extension = "rst"
    codestart = ".. code-block:: julia\n"
    codeend = "\n"
    termstart = codestart
    termend = codeend
    outputstart = "::\n"
    outputend = "\n\n"
    mimetypes = default_mime_types
    fig_ext = ".png"
    out_width = "15 cm"
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    # specials
    indent = 4
end
register_format!("rst", Rest())

function render_figures(docformat::Rest, chunk)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    result = ""
    figstring = ""

    for fig in fignames
        figstring *= @sprintf(".. image:: %s\n   :width: %s\n\n", fig, width)
    end

    if !isnothing(caption)
        result *= string(
            ".. figure:: $(fignames[1])\n",
            "   :width: $width\n\n",
            "   $caption\n\n",
        )
    else
        result *= figstring
        return result
    end
end

# Ansii
# -----

# asciidoc -b html5 -a source-highlighter=pygments ...
Base.@kwdef mutable struct AsciiDoc <: WeaveFormat
    description = "AsciiDoc"
    extension = "txt"
    codestart = "[source,julia]\n--------------------------------------"
    codeend = "--------------------------------------\n"
    termstart = codestart
    termend = codeend
    outputstart = "--------------------------------------"
    outputend = "--------------------------------------\n\n"
    mimetypes = default_mime_types
    fig_ext = ".png"
    out_width = "600"
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
end
register_format!("asciidoc", AsciiDoc())

function render_figures(docformat::AsciiDoc, chunk)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    result = ""
    figstring = ""

    for fig in fignames
        figstring *= @sprintf("image::%s[width=%s]\n", fig, width)
    end

    if !isnothing(caption)
        result *= string("image::$(fignames[1])", "[width=$width,", "title=\"$caption\"]")
    else
        result *= figstring
        return result
    end
end
