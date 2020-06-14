# Rest
# ----

Base.@kwdef mutable struct Rest <: WeaveFormat
    description = "reStructuredText and Sphinx"
    extension = "rst"
    codestart = ".. code-block:: julia\n"
    codeend = "\n\n"
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
    codeend = "--------------------------------------\n\n"
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
