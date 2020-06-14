# HTML
# ----

abstract type HTMLFormat <: WeaveFormat end

render_code(docformat::HTMLFormat, code) =
    highlight_code(MIME("text/html"), code, docformat.highlight_theme)

render_termchunk(docformat::HTMLFormat, chunk) =
    should_render(chunk) ? highlight_term(MIME("text/html"), chunk.output, docformat.highlight_theme) : ""

# Julia markdown
# --------------

Base.@kwdef mutable struct WeaveHTML <: HTMLFormat
    description = "Weave-style HTML"
    extension = "html"
    codestart = "\n"
    codeend = "\n"
    termstart = codestart
    termend = codeend
    outputstart = "<pre class=\"output\">"
    outputend = "</pre>\n"
    mimetypes = ["image/png", "image/jpg", "image/svg+xml",
                "text/html", "text/markdown", "text/plain"]
    fig_ext = ".png"
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    # specials
    template = nothing
    stylesheet = nothing
    highlight_theme = nothing
end
register_format!("md2html", WeaveHTML())

function set_format_options!(docformat::WeaveHTML; template = nothing, css = nothing, highlight_theme = nothing, _kwargs...)
    template_path = isnothing(template) ? normpath(TEMPLATE_DIR, "md2html.tpl") : template
    docformat.template = get_mustache_template(template_path)
    stylesheet_path = isnothing(css) ? normpath(STYLESHEET_DIR, "skeleton.css") : css
    docformat.stylesheet = read(stylesheet_path, String)
    docformat.highlight_theme = get_highlight_theme(highlight_theme)
end

# very similar to tex version of function
function render_chunk(docformat::WeaveHTML, chunk::DocChunk)
    out = IOBuffer()
    io = IOBuffer()
    for inline in chunk.content
        if isa(inline, InlineText)
            write(io, inline.content)
        elseif !isempty(inline.rich_output)
            clear_buffer_and_format!(io, out, WeaveMarkdown.html)
            write(out, addlines(inline.rich_output, inline))
        elseif !isempty(inline.figures)
            write(io, inline.figures[end])
        elseif !isempty(inline.output)
            write(io, addlines(inline.output, inline))
        end
    end
    clear_buffer_and_format!(io, out, WeaveMarkdown.html)
    return take2string!(out)
end

render_output(docformat::WeaveHTML, output) = Markdown.htmlesc(output)

function render_figures(docformat::WeaveHTML, chunk)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    height = chunk.options[:out_height]
    f_pos = chunk.options[:fig_pos]
    f_env = chunk.options[:fig_env]
    result = ""
    figstring = ""

    # Set size
    attribs = ""
    isnothing(width) || (attribs = "width=\"$width\"")
    (!isempty(attribs) && !isnothing(height)) && (attribs *= ",")
    isnothing(height) || (attribs *= " height=\"$height\" ")

    if !isnothing(caption)
        result *= """<figure>\n"""
    end

    for fig in fignames
        figstring *= """<img src="$fig" $attribs />\n"""
    end

    result *= figstring

    if !isnothing(caption)
        result *= """
          <figcaption>$caption</figcaption>
          """
    end

    if !isnothing(caption)
        result *= "</figure>\n"
    end

    return result
end

function render_doc(docformat::WeaveHTML, body, doc; css = nothing)
    _, weave_source = splitdir(abspath(doc.source))
    weave_version, weave_date = weave_info()

    return Mustache.render(
        docformat.template;
        body = body,
        stylesheet = docformat.stylesheet,
        highlight_stylesheet = get_highlight_stylesheet(MIME("text/html"), docformat.highlight_theme),
        header_script = doc.header_script,
        weave_source = weave_source,
        weave_version = weave_version,
        weave_date = weave_date,
        [Pair(Symbol(k), v) for (k, v) in doc.header]...,
    )
end

# Pandoc
# ------

Base.@kwdef mutable struct Pandoc2HTML <: HTMLFormat
    description = "HTML via intermediate Pandoc Markdown (requires Pandoc 2)"
    extension = "md"
    codestart = "\n"
    codeend = "\n"
    termstart = codestart
    termend = codeend
    outputstart = "\n"
    outputend = "\n"
    mimetypes = ["image/png", "image/svg+xml", "image/jpg", "text/html", "text/markdown", "text/plain"]
    fig_ext = ".png"
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    # specials
    preserve_header = true
    template_path = nothing
    stylesheet_path = nothing
    highlight_theme = nothing
    pandoc_options = String[]
end
register_format!("pandoc2html", Pandoc2HTML())

function set_format_options!(docformat::Pandoc2HTML; template = nothing, css = nothing, highlight_theme = nothing, pandoc_options = String[], _kwargs...)
    docformat.template_path =
        isnothing(template) ? normpath(TEMPLATE_DIR, "pandoc2html.html") : template
    docformat.stylesheet_path =
        isnothing(css) ? normpath(STYLESHEET_DIR, "pandoc2html_skeleton.css") : css
    docformat.highlight_theme = get_highlight_theme(highlight_theme)
    docformat.pandoc_options = pandoc_options
end

render_figures(docformat::Pandoc2HTML, chunk) = render_figures(Pandoc(), chunk)
