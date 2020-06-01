# Rest
# ----

Base.@kwdef mutable struct Rest <: WeaveFormat
    description = "reStructuredText and Sphinx"
    codestart = ".. code-block:: julia\n"
    codeend = "\n\n"
    outputstart = "::\n"
    outputend = "\n\n"
    indent = 4
    fig_ext = ".png"
    extension = "rst"
    keep_unicode = false
    termstart = codestart
    termend = codeend
    out_width = "15 cm"
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    highlight_theme = nothing
    #this could be removed if argument parsing checked whether the format was
    # compatible with templates
    template = nothing
    mimetypes = default_mime_types
end
register_format!("rst", Rest())

function formatfigures(chunk, docformat::Rest)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    result = ""
    figstring = ""

    for fig in fignames
        figstring *= @sprintf(".. image:: %s\n   :width: %s\n\n", fig, width)
    end

    if caption != nothing
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
    codestart = "[source,julia]\n--------------------------------------"
    codeend = "--------------------------------------\n\n"
    outputstart = "--------------------------------------"
    outputend = "--------------------------------------\n\n"
    fig_ext = ".png"
    extension = "txt"
    keep_unicode = false
    termstart = codestart
    termend = codeend
    out_width = "600"
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    highlight_theme = nothing
    #this could be removed
    template = nothing
    mimetypes = default_mime_types
end
register_format!("asciidoc", AsciiDoc())

function formatfigures(chunk, docformat::AsciiDoc)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    result = ""
    figstring = ""

    for fig in fignames
        figstring *= @sprintf("image::%s[width=%s]\n", fig, width)
    end

    if caption != nothing
        result *= string("image::$(fignames[1])", "[width=$width,", "title=\"$caption\"]")
    else
        result *= figstring
        return result
    end
end
