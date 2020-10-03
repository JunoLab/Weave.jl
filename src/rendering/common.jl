# fallback methods
# ----------------

set_format_options!(docformat::WeaveFormat; _kwargs...) = return

function restore_header!(doc)
    (hasproperty(doc.format, :preserve_header) && doc.format.preserve_header) || return

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

render_chunk(docformat::WeaveFormat, chunk::DocChunk) = join((render_inline(c) for c in chunk.content))

render_inline(inline::InlineText) = inline.content

function render_inline(inline::InlineCode)
    isempty(inline.rich_output) || return inline.rich_output
    isempty(inline.figures) || return inline.figures[end]
    return inline.output
end

function render_chunk(docformat::WeaveFormat, chunk::CodeChunk)

    # Fill undefined options with format specific defaults
    isnothing(chunk.options[:out_width]) && (chunk.options[:out_width] = docformat.out_width)
    isnothing(chunk.options[:fig_pos]) && (chunk.options[:fig_pos] = docformat.fig_pos)

    # Only use floats if chunk has caption or sets fig_env
    if !isnothing(chunk.options[:fig_cap]) && isnothing(chunk.options[:fig_env])
        (chunk.options[:fig_env] = docformat.fig_env)
    end

    hasproperty(docformat, :indent) && (chunk.content = indent(chunk.content, docformat.indent))

    chunk.content = render_code(docformat, chunk.content)

    echo = chunk.options[:echo]

    chunk.options[:eval] || return echo ? string(docformat.codestart, chunk.content, docformat.codeend) : ""

    if chunk.options[:term]
        result = render_termchunk(docformat, chunk)
    else
        result = if echo
            # Convert to output format and highlight (html, tex...) if needed
            string(docformat.codestart, chunk.content, docformat.codeend, '\n')
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
                    chunk.output = render_output(docformat, chunk.output)
                else
                    chunk.output = '\n' * rstrip(chunk.output)
                    chunk.output = render_output(docformat, chunk.output)
                end

                hasproperty(docformat, :indent) && (chunk.output = indent(chunk.output, docformat.indent))

                strip(chunk.output) ≠ "" && (
                    result *= "$(docformat.outputstart)$(chunk.output)\n$(docformat.outputend)\n"
                )
                strip(chunk.rich_output) ≠ "" && (result *= chunk.rich_output * '\n')
            end
        end
    end

    # Handle figures
    if chunk.options[:fig] && length(chunk.figures) > 0
        result *= render_figures(docformat, chunk)
    end

    return result
end

render_code(docformat::WeaveFormat, code) = code

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

render_output(docformat::WeaveFormat, output) = output

function render_termchunk(docformat::WeaveFormat, chunk)
    return if should_render(chunk)
        string(docformat.termstart, chunk.output, docformat.termend)
    else
        ""
    end
end

should_render(chunk) = chunk.options[:echo] && chunk.options[:results] ≠ "hidden"

render_doc(docformat, body, doc) = body

# utilities
# ---------

function clear_buffer_and_format!(io::IOBuffer, out::IOBuffer, render_function)
    text = take2string!(io)
    m = Markdown.parse(text, flavor = WeaveMarkdown.weavemd)
    write(out, string(render_function(m)))
end

addlines(op, inline) = inline.ctype === :line ? string('\n', op, '\n') : op

get_mustache_template(path::AbstractString) = Mustache.template_from_file(path)
get_mustache_template(tpl::Mustache.MustacheTokens) = tpl

get_highlight_stylesheet(mime, highlight_theme) =
    get_highlight_stylesheet(mime, get_highlight_theme(highlight_theme))
get_highlight_stylesheet(mime, highlight_theme::Type{<:Highlights.AbstractTheme}) =
    sprint((io, x) -> Highlights.stylesheet(io, mime, x), highlight_theme)

get_highlight_theme(::Nothing) = Highlights.Themes.DefaultTheme
get_highlight_theme(highlight_theme::Type{<:Highlights.AbstractTheme}) = highlight_theme

highlight_code(mime, code, highlight_theme) =
    highlight(mime, strip(code), Highlights.Lexers.JuliaLexer, highlight_theme)
highlight_term(mime, output, highlight_theme) =
    highlight(mime, strip(output), Highlights.Lexers.JuliaConsoleLexer, highlight_theme)
highlight(mime, output, lexer, theme = Highlights.Themes.DefaultTheme) =
    sprint((io, x) -> Highlights.highlight(io, mime, x, lexer, theme), output)
