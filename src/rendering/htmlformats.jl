# HTML
# ----
abstract type HTMLFormat <: WeaveFormat end

Base.@kwdef mutable struct JMarkdown2HTML <: HTMLFormat
    description = "Julia markdown to html"
    codestart = "\n"
    codeend = "\n"
    outputstart = "<pre class=\"output\">"
    outputend = "</pre>\n"
    fig_ext = ".png"
    mimetypes = ["image/png", "image/jpg", "image/svg+xml",
                "text/html", "text/markdown", "text/plain"]
    keep_unicode = false
    extension = "html"
    termstart = codestart
    termend = codeend
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    highlight_theme = nothing
end
register_format!("md2html", JMarkdown2HTML())

Base.@kwdef mutable struct Pandoc2HTML <: HTMLFormat
    description = "Markdown to HTML (requires Pandoc 2)"
    codestart = "\n"
    codeend = "\n"
    outputstart = "\n"
    outputend = "\n"
    fig_ext = ".png"
    extension = "md"
    mimetypes = ["image/png", "image/svg+xml", "image/jpg",
                "text/html", "text/markdown", "text/plain"]
    keep_unicode = false
    termstart = codestart
    termend = codeend
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    highlight_theme = nothing
end
register_format!("pandoc2html", Pandoc2HTML())


function render_doc(::JMarkdown2HTML, body, doc, template, css, highlight_theme)
    _, weave_source = splitdir(abspath(doc.source))
    weave_version, weave_date = weave_info()

    return Mustache.render(
        get_html_template(template);
        body = body,
        stylesheet = get_stylesheet(css),
        highlight_stylesheet = get_highlight_stylesheet(MIME("text/html"), highlight_theme),
        header_script = doc.header_script,
        weave_source = weave_source,
        weave_version = weave_version,
        weave_date = weave_date,
        [Pair(Symbol(k), v) for (k, v) in doc.header]...,
    )
end


function format_chunk(chunk::DocChunk, docformat::JMarkdown2HTML)
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

format_output(result, docformat::JMarkdown2HTML) = Markdown.htmlesc(result)

format_code(code, docformat::HTMLFormat) =
    highlight_code(MIME("text/html"), code, docformat.highlight_theme)

format_termchunk(chunk, docformat::HTMLFormat) =
    should_render(chunk) ? highlight_term(MIME("text/html"), chunk.output, docformat.highlight_theme) : ""

formatfigures(chunk, docformat::Pandoc2HTML) = formatfigures(chunk, pandoc)

function formatfigures(chunk, docformat::JMarkdown2HTML)
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
    width == nothing || (attribs = "width=\"$width\"")
    (attribs != "" && height != nothing) && (attribs *= ",")
    height == nothing || (attribs *= " height=\"$height\" ")

    if caption != nothing
        result *= """<figure>\n"""
    end

    for fig in fignames
        figstring *= """<img src="$fig" $attribs />\n"""
    end

    result *= figstring

    if caption != nothing
        result *= """
          <figcaption>$caption</figcaption>
          """
    end

    if caption != nothing
        result *= "</figure>\n"
    end

    return result
end
