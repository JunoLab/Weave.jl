# TODO: reorganize this file into multiple files corresponding to each output format

using Mustache, Highlights, .WeaveMarkdown, Markdown, Dates, Pkg
using REPL.REPLCompletions: latex_symbols

function format(doc, template = nothing, highlight_theme = nothing; css = nothing)
    docformat = doc.format

    # Complete format dictionaries with defaults
    get!(docformat.formatdict, :termstart, docformat.formatdict[:codestart])
    get!(docformat.formatdict, :termend, docformat.formatdict[:codeend])
    get!(docformat.formatdict, :out_width, nothing)
    get!(docformat.formatdict, :out_height, nothing)
    get!(docformat.formatdict, :fig_pos, nothing)
    get!(docformat.formatdict, :fig_env, nothing)
    docformat.formatdict[:highlight_theme] = highlight_theme = get_highlight_theme(highlight_theme)

    restore_header!(doc)

    lines = map(copy(doc.chunks)) do chunk
        format_chunk(chunk, docformat)
    end
    body = join(lines, '\n')

    return docformat isa JMarkdown2HTML ? render2html(body, doc, template, css, highlight_theme) :
           docformat isa JMarkdown2tex ? render2tex(body, doc, template, highlight_theme) :
           body
end

function render2html(body, doc, template, css, highlight_theme)
    _, weave_source = splitdir(abspath(doc.source))
    weave_version, weave_date = weave_info()

    return Mustache.render(
        get_template(template, false);
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

function render2tex(body, doc, template, highlight_theme)
    return Mustache.render(
        get_template(template, true);
        body = body,
        highlight = get_highlight_stylesheet(MIME("text/latex"), highlight_theme),
        [Pair(Symbol(k), v) for (k, v) in doc.header]...,
    )
end

get_highlight_theme(::Nothing) = Highlights.Themes.DefaultTheme
get_highlight_theme(highlight_theme::Type{<:Highlights.AbstractTheme}) = highlight_theme

get_template(::Nothing, tex::Bool = false) =
    Mustache.template_from_file(normpath(TEMPLATE_DIR, tex ? "julia_tex.tpl" : "julia_html.tpl"))
get_template(path::AbstractString, tex) = Mustache.template_from_file(path)
get_template(tpl::Mustache.MustacheTokens, tex) = tpl

get_stylesheet(::Nothing) = get_stylesheet(normpath(TEMPLATE_DIR, "skeleton_css.css"))
get_stylesheet(path::AbstractString) = read(path, String)

get_highlight_stylesheet(mime, highlight_theme) =
    sprint((io, x) -> Highlights.stylesheet(io, mime, x), highlight_theme)

const WEAVE_VERSION = try
    'v' * Pkg.TOML.parsefile(normpath(PKG_DIR, "Project.toml"))["version"]
catch
    ""
end

weave_info() = WEAVE_VERSION, string(Date(now()))

# TODO: is there any other format where we want to restore headers ?
const HEADER_PRESERVE_DOCTYPES = ("github", "hugo")

function restore_header!(doc)
    doc.doctype in HEADER_PRESERVE_DOCTYPES || return # don't restore

    # only strips Weave headers
    delete!(doc.header, WEAVE_OPTION_NAME)
    if haskey(doc.header, WEAVE_OPTION_NAME_DEPRECATED)
        @warn "Weave: `options` key is deprecated. Use `weave_options` key instead." _id = WEAVE_OPTION_DEPRECATE_ID maxlog = 1
        delete!(doc.header, WEAVE_OPTION_NAME_DEPRECATED)
    end
    isempty(doc.header) && return

    # restore remained headers as `DocChunk`
    header_text = "---\n$(YAML.write(doc.header))---"
    pushfirst!(doc.chunks, DocChunk(header_text, 0, 0))
end

format_chunk(chunk::DocChunk, docformat) = join((format_inline(c) for c in chunk.content))

format_inline(inline::InlineText) = inline.content

function format_inline(inline::InlineCode)
    isempty(inline.rich_output) || return inline.rich_output
    isempty(inline.figures) || return inline.figures[end]
    return inline.output
end

function format_chunk(chunk::DocChunk, docformat::JMarkdown2tex)
    out = IOBuffer()
    io = IOBuffer()
    for inline in chunk.content
        if isa(inline, InlineText)
            write(io, inline.content)
        elseif !isempty(inline.rich_output)
            clear_buffer_and_format!(io, out, WeaveMarkdown.latex)
            write(out, addlines(inline.rich_output, inline))
        elseif !isempty(inline.figures)
            write(io, inline.figures[end], inline)
        elseif !isempty(inline.output)
            write(io, addlines(inline.output, inline))
        end
    end
    clear_buffer_and_format!(io, out, WeaveMarkdown.latex)
    out = take2string!(out)
    return docformat.formatdict[:keep_unicode] ? out : uc2tex(out)
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

function clear_buffer_and_format!(io::IOBuffer, out::IOBuffer, render_function)
    text = take2string!(io)
    m = Markdown.parse(text, flavor = WeaveMarkdown.weavemd)
    write(out, string(render_function(m)))
end

addlines(op, inline) = inline.ctype === :line ? string('\n', op, '\n') : op

function format_chunk(chunk::CodeChunk, docformat)
    formatdict = docformat.formatdict

    # Fill undefined options with format specific defaults
    isnothing(chunk.options[:out_width]) && (chunk.options[:out_width] = formatdict[:out_width])
    isnothing(chunk.options[:fig_pos]) && (chunk.options[:fig_pos] = formatdict[:fig_pos])

    # Only use floats if chunk has caption or sets fig_env
    if !isnothing(chunk.options[:fig_cap]) && isnothing(chunk.options[:fig_env])
        (chunk.options[:fig_env] = formatdict[:fig_env])
    end

    haskey(formatdict, :indent) && (chunk.content = indent(chunk.content, formatdict[:indent]))

    chunk.content = format_code(chunk.content, docformat)

    if !chunk.options[:eval]
        return if chunk.options[:echo]
            string(formatdict[:codestart], '\n', chunk.content, formatdict[:codeend])
        else
            ""
        end
    end

    if chunk.options[:term]
        result = format_termchunk(chunk, docformat)
    else
        result = if chunk.options[:echo]
            # Convert to output format and highlight (html, tex...) if needed
            string(formatdict[:codestart], chunk.content, formatdict[:codeend], '\n')
        else
            ""
        end

        if (strip(chunk.output) ≠ "" || strip(chunk.rich_output) ≠ "") &&
           (chunk.options[:results] ≠ "hidden")
            if chunk.options[:results] ≠ "markup" && chunk.options[:results] ≠ "hold"
                strip(chunk.output) ≠ "" && (result *= "$(chunk.output)\n")
                strip(chunk.rich_output) ≠ "" && (result *= "$(chunk.rich_output)\n")
            else
                if chunk.options[:wrap]
                    chunk.output =
                        '\n' * wraplines(chunk.output, chunk.options[:line_width])
                    chunk.output = format_output(chunk.output, docformat)
                else
                    chunk.output = '\n' * rstrip(chunk.output)
                    chunk.output = format_output(chunk.output, docformat)
                end

                if haskey(formatdict, :indent)
                    chunk.output = indent(chunk.output, formatdict[:indent])
                end
                strip(chunk.output) ≠ "" && (
                    result *= "$(formatdict[:outputstart])$(chunk.output)\n$(formatdict[:outputend])\n"
                )
                strip(chunk.rich_output) ≠ "" && (result *= chunk.rich_output * '\n')
            end
        end
    end

    # Handle figures
    if chunk.options[:fig] && length(chunk.figures) > 0
        if chunk.options[:include]
            result *= formatfigures(chunk, docformat)
        end
    end

    return result
end

format_output(result, docformat) = result

format_output(result, docformat::JMarkdown2HTML) = Markdown.htmlesc(result)

function format_output(result, docformat::JMarkdown2tex)
    # Highligts has some extra escaping defined, eg of $, ", ...
    result_escaped = sprint(
        (io, x) ->
            Highlights.Format.escape(io, MIME("text/latex"), x, charescape = true),
        result,
    )
    docformat.formatdict[:keep_unicode] || return uc2tex(result_escaped, true)
    return result_escaped
end

format_code(code, docformat) = code

# return "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}\n$result\n\\end{minted}\n"
function format_code(code, docformat::JMarkdown2tex)
    ret = highlight_code(MIME("text/latex"), code, docformat.formatdict[:highlight_theme])
    docformat.formatdict[:keep_unicode] || return uc2tex(ret)
    return ret
end

# Convert unicode to tex, escape listings if needed
function uc2tex(s, escape = false)
    for key in keys(latex_symbols)
        if escape
            s = replace(s, latex_symbols[key] => "(*@\\ensuremath{$(texify(key))}@*)")
        else
            s = replace(s, latex_symbols[key] => "\\ensuremath{$(texify(key))}")
        end
    end
    return s
end

# Make julia symbols (\bf* etc.) valid latex
function texify(s)
    return if occursin(r"^\\bf[A-Z]$", s)
        replace(s, "\\bf" => "\\bm{\\mathrm{") * "}}"
    elseif startswith(s, "\\bfrak")
        replace(s, "\\bfrak" => "\\bm{\\mathfrak{") * "}}"
    elseif startswith(s, "\\bf")
        replace(s, "\\bf" => "\\bm{\\") * "}"
    elseif startswith(s, "\\frak")
        replace(s, "\\frak" => "\\mathfrak{") * "}"
    else
        s
    end
end

format_code(code, docformat::JMarkdown2HTML) =
    highlight_code(MIME("text/html"), code, docformat.formatdict[:highlight_theme])

format_code(code, docformat::Pandoc2HTML) =
    highlight_code(MIME("text/html"), code, docformat.formatdict[:highlight_theme])

function format_termchunk(chunk, docformat)
    return if should_render(chunk)
        fd = docformat.formatdict
        string(fd[:termstart], chunk.output, '\n', fd[:termend], '\n')
    else
        ""
    end
end

format_termchunk(chunk, docformat::JMarkdown2HTML) =
    should_render(chunk) ? highlight_term(MIME("text/html"), chunk.output, docformat.formatdict[:highlight_theme]) : ""

format_termchunk(chunk, docformat::Pandoc2HTML) =
    should_render(chunk) ? highlight_term(MIME("text/html"), chunk.output, docformat.formatdict[:highlight_theme]) : ""

# return "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}\n$result\n\\end{minted}\n"
format_termchunk(chunk, docformat::JMarkdown2tex) =
    should_render(chunk) ? highlight_term(MIME("text/latex"), chunk.output, docformat.formatdict[:highlight_theme]) : ""

should_render(chunk) = chunk.options[:echo] && chunk.options[:results] ≠ "hidden"

highlight_code(mime, code, highlight_theme) =
    highlight(mime, strip(code), Highlights.Lexers.JuliaLexer, highlight_theme)
highlight_term(mime, output, highlight_theme) =
    highlight(mime, strip(output), Highlights.Lexers.JuliaConsoleLexer, highlight_theme)
highlight(mime, output, lexer, theme = Highlights.Themes.DefaultTheme) =
    sprint((io, x) -> Highlights.highlight(io, mime, x, lexer, theme), output)

indent(text, nindent) = join(map(x -> string(repeat(' ', nindent), x), split(text, '\n')), '\n')

function wraplines(text, line_width = 75)
    result = AbstractString[]
    lines = split(text, '\n')
    for line in lines
        if length(line) > line_width
            push!(result, wrapline(line, line_width))
        else
            push!(result, line)
        end
    end

    return strip(join(result, '\n'))
end

function wrapline(text, line_width = 75)
    result = ""
    while length(text) > line_width
        result *= first(text, line_width) * '\n'
        text = chop(text, head = line_width, tail = 0)
    end
    result *= text
end
