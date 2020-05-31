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




function formatfigures(chunk, docformat::Pandoc)
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
    width == nothing || push!(attribs, "width=$width")
    height == nothing || push!(attribs, "height=$height")
    label == nothing || push!(attribs, "#fig:$label")
    attribs = isempty(attribs) ? "" : "{" * join(attribs, " ") * "}"

    if caption != nothing
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
