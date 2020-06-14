# HTML
# ----

abstract type HTMLFormat <: WeaveFormat end

format_code(code, docformat::HTMLFormat) =
    highlight_code(MIME("text/html"), code, docformat.highlight_theme)

format_termchunk(chunk, docformat::HTMLFormat) =
    should_render(chunk) ? highlight_term(MIME("text/html"), chunk.output, docformat.highlight_theme) : ""

# Julia markdown
# --------------

Base.@kwdef mutable struct JMarkdown2HTML <: HTMLFormat
    description = "Julia markdown to html"
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
register_format!("md2html", JMarkdown2HTML())

function set_format_options!(docformat::JMarkdown2HTML; template = nothing, css = nothing, highlight_theme = nothing, _kwargs...)
    docformat.template = get_html_template(template)
    docformat.stylesheet = get_stylesheet(css)
    docformat.highlight_theme = get_highlight_theme(highlight_theme)
end

get_html_template(::Nothing) = get_mustache_template(normpath(TEMPLATE_DIR, "md2html.tpl"))
get_html_template(x) = get_mustache_template(x)

get_stylesheet(::Nothing) = get_stylesheet(normpath(STYLESHEET_DIR, "skeleton.css"))
get_stylesheet(path::AbstractString) = read(path, String)

# very similar to tex version of function
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

function render_doc(docformat::JMarkdown2HTML, body, doc; css = nothing)
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
    description = "Markdown to HTML (requires Pandoc 2)"
    extension = "md"
    codestart = "\n"
    codeend = "\n"
    termstart = codestart
    termend = codeend
    outputstart = "\n"
    outputend = "\n"
    mimetypes = ["image/png", "image/svg+xml", "image/jpg",
                "text/html", "text/markdown", "text/plain"]
    fig_ext = ".png"
    out_width = nothing
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
end
register_format!("pandoc2html", Pandoc2HTML())

formatfigures(chunk, docformat::Pandoc2HTML) = formatfigures(chunk, Pandoc())
