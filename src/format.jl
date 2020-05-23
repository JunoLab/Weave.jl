using Mustache, Highlights, .WeaveMarkdown, Markdown, Dates, Pkg
using REPL.REPLCompletions: latex_symbols

function format(doc, template = nothing, highlight_theme = nothing; css = nothing)
    format = doc.format

    # Complete format dictionaries with defaults
    formatdict = format.formatdict
    get!(formatdict, :termstart, formatdict[:codestart])
    get!(formatdict, :termend, formatdict[:codeend])
    get!(formatdict, :out_width, nothing)
    get!(formatdict, :out_height, nothing)
    get!(formatdict, :fig_pos, nothing)
    get!(formatdict, :fig_env, nothing)

    formatdict[:theme] = highlight_theme = get_highlight_theme(highlight_theme)

    restore_header!(doc)

    lines = map(copy(doc.chunks)) do chunk
        format_chunk(chunk, formatdict, format)
    end
    body = join(lines, '\n')

    return format isa JMarkdown2HTML ? render2html(body, doc, template, css, highlight_theme) :
           format isa JMarkdown2tex ? render2tex(body, doc, template, highlight_theme) :
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
        @warn "Weave: `options` key is deprecated. Use `weave_options` key instead."
        delete!(doc.header, WEAVE_OPTION_NAME_DEPRECATED)
    end
    isempty(doc.header) && return

    # restore remained headers as `DocChunk`
    header_text = "---\n$(YAML.write(doc.header))---"
    pushfirst!(doc.chunks, DocChunk(header_text, 0, 0))
end

format_chunk(chunk::DocChunk, formatdict, docformat) = join((format_inline(c) for c in chunk.content))

format_inline(inline::InlineText) = inline.content

function format_inline(inline::InlineCode)
    isempty(inline.rich_output) || return inline.rich_output
    isempty(inline.figures) || return inline.figures[end]
    return inline.output
end

function ioformat!(io::IOBuffer, out::IOBuffer, fun = WeaveMarkdown.latex)
    text = String(take!(io))
    if !isempty(text)
        m = Markdown.parse(text, flavor = WeaveMarkdown.weavemd)
        write(out, string(fun(m)))
    end
end

addspace(op, inline) = (inline.ctype === :line && (op = "\n$op\n"); op)

function format_chunk(chunk::DocChunk, formatdict, docformat::JMarkdown2tex)
    out = IOBuffer()
    io = IOBuffer()
    for inline in chunk.content
        if isa(inline, InlineText)
            write(io, inline.content)
        elseif !isempty(inline.rich_output)
            ioformat!(io, out)
            write(out, addspace(inline.rich_output, inline))
        elseif !isempty(inline.figures)
            write(io, inline.figures[end], inline)
        elseif !isempty(inline.output)
            write(io, addspace(inline.output, inline))
        end
    end
    ioformat!(io, out)
    formatdict[:keep_unicode] || return uc2tex(String(take!(out)))
    return String(take!(out))
end

function format_chunk(chunk::DocChunk, formatdict, docformat::JMarkdown2HTML)
    out = IOBuffer()
    io = IOBuffer()
    fun = WeaveMarkdown.html
    for inline in chunk.content
        if isa(inline, InlineText)
            write(io, inline.content)
        elseif !isempty(inline.rich_output)
            ioformat!(io, out, fun)
            write(out, addspace(inline.rich_output, inline))
        elseif !isempty(inline.figures)
            write(io, inline.figures[end])
        elseif !isempty(inline.output)
            write(io, addspace(inline.output, inline))
        end
    end
    ioformat!(io, out, fun)
    return String(take!(out))
end

function format_chunk(chunk::CodeChunk, formatdict, docformat)
    # Fill undefined options with format specific defaults
    chunk.options[:out_width] == nothing &&
        (chunk.options[:out_width] = formatdict[:out_width])
    chunk.options[:fig_pos] == nothing && (chunk.options[:fig_pos] = formatdict[:fig_pos])

    # Only use floats if chunk has caption or sets fig_env
    if chunk.options[:fig_cap] != nothing && chunk.options[:fig_env] == nothing
        (chunk.options[:fig_env] = formatdict[:fig_env])
    end

    if haskey(formatdict, :indent)
        chunk.content = indent(chunk.content, formatdict[:indent])
    end

    chunk.content = format_code(chunk.content, docformat)

    if !chunk.options[:eval]
        if chunk.options[:echo]
            result = "$(formatdict[:codestart])\n$(chunk.content)$(formatdict[:codeend])"
            return result
        else
            r = ""
            return r
        end
    end

    if chunk.options[:term]
        result = format_termchunk(chunk, formatdict, docformat)
    else

        if chunk.options[:echo]
            # Convert to output format and highlight (html, tex...) if needed
            result = "$(formatdict[:codestart])$(chunk.content)$(formatdict[:codeend])\n"
        else
            result = ""
        end

        if (strip(chunk.output) != "" || strip(chunk.rich_output) != "") &&
           (chunk.options[:results] != "hidden")
            if chunk.options[:results] != "markup" && chunk.options[:results] != "hold"
                strip(chunk.output) ≠ "" && (result *= "$(chunk.output)\n")
                strip(chunk.rich_output) ≠ "" && (result *= "$(chunk.rich_output)\n")
            else
                if chunk.options[:wrap]
                    chunk.output =
                        "\n" * wraplines(chunk.output, chunk.options[:line_width])
                    chunk.output = format_output(chunk.output, docformat)
                else
                    chunk.output = "\n" * rstrip(chunk.output)
                    chunk.output = format_output(chunk.output, docformat)
                end

                if haskey(formatdict, :indent)
                    chunk.output = indent(chunk.output, formatdict[:indent])
                end
                strip(chunk.output) ≠ "" && (
                    result *= "$(formatdict[:outputstart])$(chunk.output)\n$(formatdict[:outputend])\n"
                )
                strip(chunk.rich_output) ≠ "" && (result *= chunk.rich_output * "\n")
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

format_code(result, docformat) = result

function format_code(result, docformat::JMarkdown2tex)
    highlighted = highlight(
        MIME("text/latex"),
        strip(result),
        Highlights.Lexers.JuliaLexer,
        docformat.formatdict[:theme],
    )
    docformat.formatdict[:keep_unicode] || return uc2tex(highlighted)
    return highlighted
    # return "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}\n$result\n\\end{minted}\n"
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
    ts = ""
    if occursin(r"^\\bf[A-Z]$", s)
        ts = replace(s, "\\bf" => "\\bm{\\mathrm{") * "}}"
    elseif startswith(s, "\\bfrak")
        ts = replace(s, "\\bfrak" => "\\bm{\\mathfrak{") * "}}"
    elseif startswith(s, "\\bf")
        ts = replace(s, "\\bf" => "\\bm{\\") * "}"
    elseif startswith(s, "\\frak")
        ts = replace(s, "\\frak" => "\\mathfrak{") * "}"
    else
        ts = s
    end
    return ts
end

function format_code(result, docformat::JMarkdown2HTML)
    return highlight(
        MIME("text/html"),
        strip(result),
        Highlights.Lexers.JuliaLexer,
        docformat.formatdict[:theme],
    )
end

function format_code(result, docformat::Pandoc2HTML)
    return highlight(
        MIME("text/html"),
        strip(result),
        Highlights.Lexers.JuliaLexer,
        docformat.formatdict[:theme],
    )
end

function format_termchunk(chunk, formatdict, docformat)
    if chunk.options[:echo] && chunk.options[:results] != "hidden"
        result = "$(formatdict[:termstart])$(chunk.output)\n" * "$(formatdict[:termend])\n"
    else
        result = ""
    end
    return result
end

function format_termchunk(chunk, formatdict, docformat::JMarkdown2HTML)
    if chunk.options[:echo] && chunk.options[:results] != "hidden"
        result = highlight(
            MIME("text/html"),
            strip(chunk.output),
            Highlights.Lexers.JuliaConsoleLexer,
            docformat.formatdict[:theme],
        )
    else
        result = ""
    end
    return result
end

function format_termchunk(chunk, formatdict, docformat::Pandoc2HTML)
    if chunk.options[:echo] && chunk.options[:results] != "hidden"
        result = highlight(
            MIME("text/html"),
            strip(chunk.output),
            Highlights.Lexers.JuliaConsoleLexer,
            docformat.formatdict[:theme],
        )
    else
        result = ""
    end
    return result
end

function format_termchunk(chunk, formatdict, docformat::JMarkdown2tex)
    if chunk.options[:echo] && chunk.options[:results] != "hidden"
        result = highlight(
            MIME("text/latex"),
            strip(chunk.output),
            Highlights.Lexers.JuliaConsoleLexer,
            docformat.formatdict[:theme],
        )
        # return "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}\n$result\n\\end{minted}\n"
    else
        result = ""
    end
    return result
end

function highlight(
    mime::MIME,
    output,
    lexer,
    theme = Highlights.Themes.DefaultTheme,
)
    return sprint((io, x) -> Highlights.highlight(io, mime, x, lexer, theme), output)
end

indent(text, nindent) = join(map(x -> string(repeat(' ', nindent), x), split(text, '\n')), '\n')

function wraplines(text, line_width = 75)
    result = AbstractString[]
    lines = split(text, "\n")
    for line in lines
        if length(line) > line_width
            push!(result, wrapline(line, line_width))
        else
            push!(result, line)
        end
    end

    return strip(join(result, "\n"))
end

function wrapline(text, line_width = 75)
    result = ""
    while length(text) > line_width
        result *= first(text, line_width) * "\n"
        text = chop(text, head = line_width, tail = 0)
    end
    result *= text
end
