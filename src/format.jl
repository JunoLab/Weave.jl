import Mustache, Highlights
import .WeaveMarkdown
using Compat
using Dates
using Markdown
using REPL.REPLCompletions: latex_symbols


function format(doc::WeaveDoc)
    formatted = AbstractString[]
    docformat = doc.format

    #Complete format dictionaries with defaults
    formatdict = docformat.formatdict
    get!(formatdict, :termstart, formatdict[:codestart])
    get!(formatdict, :termend, formatdict[:codeend])
    get!(formatdict, :out_width, nothing)
    get!(formatdict, :out_height, nothing)
    get!(formatdict, :fig_pos, nothing)
    get!(formatdict, :fig_env, nothing)

    docformat.formatdict[:cwd] = doc.cwd #pass wd to figure formatters
    docformat.formatdict[:theme] = doc.highlight_theme

    #strip header
    if isa(doc.chunks[1], DocChunk)
        if !occursin("pandoc", doc.doctype)
            doc.chunks[1] = strip_header(doc.chunks[1])
        end
    end

    for chunk in copy(doc.chunks)
        result = format_chunk(chunk, formatdict, docformat)
        push!(formatted, result)
    end

    formatted = join(formatted, "\n")
    # Render using a template if needed
    rendered = render_doc(formatted, doc, doc.format)

    return rendered
end

"""
  render_doc(formatted::AbstractString, format)

Render formatted document to a template
"""
function render_doc(formatted, doc::WeaveDoc, format)
  return formatted
end

function highlight(mime::MIME, source::AbstractString, lexer, theme=Highlights.Themes.DefaultTheme)
    return sprint( (io, x) -> Highlights.highlight(io, mime, x, lexer, theme), source)
end

function stylesheet(m::MIME, theme)
  return sprint( (io, x) ->  Highlights.stylesheet(io, m, x), theme)
end

function render_doc(formatted, doc::WeaveDoc, format::JMarkdown2HTML)
  css = stylesheet(MIME("text/html"), doc.highlight_theme)
  path, wsource = splitdir(abspath(doc.source))
  #wversion = string(Pkg.installed("Weave"))
  wversion = ""
  wtime =  string(Date(now()))

  if isempty(doc.css)
    theme_css = read(joinpath(dirname(@__FILE__), "../templates/skeleton_css.css"), String)
  else
    theme_css = read(doc.css, String)
  end

  if isa(doc.template, Mustache.MustacheTokens)
    template = doc.template
  elseif isempty(doc.template)
    template = Mustache.template_from_file(joinpath(dirname(@__FILE__), "../templates/julia_html.tpl"))
  else
    template = Mustache.template_from_file(doc.template)
  end

  return Mustache.render(template; themecss = theme_css,
                          highlightcss = css, body = formatted, header_script = doc.header_script,
                          source = wsource, wtime = wtime, wversion = wversion,
                          [Pair(Symbol(k), v) for (k,v) in doc.header]...)
end

function render_doc(formatted, doc::WeaveDoc, format::JMarkdown2tex)
  highlight = stylesheet(MIME("text/latex"), doc.highlight_theme)
  path, wsource = splitdir(abspath(doc.source))
  #wversion = string(Pkg.installed("Weave"))
  wversion = ""
  wtime =  string(Date(now()))



  if isa(doc.template, Mustache.MustacheTokens)
      template = doc.template
  elseif isempty(doc.template)
    template = Mustache.template_from_file(joinpath(dirname(@__FILE__), "../templates/julia_tex.tpl"))
  else
    template = Mustache.template_from_file(doc.template)
  end

  return Mustache.render(template; body = formatted,
    highlight = highlight,
    [Pair(Symbol(k), v) for (k,v) in doc.header]...)
end

function strip_header(chunk::DocChunk)
  if occursin(r"^---$(?<header>.+)^---$"ms, chunk.content[1].content)
    chunk.content[1].content = lstrip(replace(chunk.content[1].content, r"^---$(?<header>.+)^---$"ms => ""))
  end
  return chunk
end

function format_chunk(chunk::DocChunk, formatdict, docformat)
    return join([format_inline(c) for c in chunk.content], "")
end

function format_inline(inline::InlineText)
    return inline.content
end

function format_inline(inline::InlineCode)
    isempty(inline.rich_output) || return inline.rich_output
    isempty(inline.figures) || return inline.figures[end]
    isempty(inline.output) || return inline.output
end

function ioformat!(io::IOBuffer, out::IOBuffer, fun=WeaveMarkdown.latex)
    text = String(take!(io))
    if !isempty(text)
        m = Markdown.parse(text, flavor=WeaveMarkdown.weavemd)
        write(out, string(fun(m)))
    end
end

function addspace(op, inline)
    inline.ctype == :line && (op = "\n$op\n")
    return op
end

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
    return uc2tex(String(take!(out)))
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
    #Fill undefined options with format specific defaults
    chunk.options[:out_width] == nothing &&
        (chunk.options[:out_width] =  formatdict[:out_width])
    chunk.options[:fig_pos] == nothing &&
        (chunk.options[:fig_pos] =  formatdict[:fig_pos])

    #Only use floats if chunk has caption or sets fig_env
    if chunk.options[:fig_cap] != nothing && chunk.options[:fig_env] == nothing
        (chunk.options[:fig_env] =  formatdict[:fig_env])
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
      #Convert to output format and highlight (html, tex...) if needed
        result = "$(formatdict[:codestart])$(chunk.content)$(formatdict[:codeend])\n"
    else
        result = ""
    end

    if (strip(chunk.output)!= "" || strip(chunk.rich_output) != "") && (chunk.options[:results] != "hidden")
        if chunk.options[:results] != "markup" && chunk.options[:results] != "hold"
            strip(chunk.output) ≠ "" && (result *= "$(chunk.output)\n")
            strip(chunk.rich_output) ≠ "" && (result *= "$(chunk.rich_output)\n")
        else
            if chunk.options[:wrap]
                chunk.output = "\n" * wraplines(chunk.output, chunk.options[:line_width])
                chunk.output = format_output(chunk.output, docformat)
            else
                chunk.output = "\n" * rstrip(chunk.output)
                chunk.output = format_output(chunk.output, docformat)
            end

            if haskey(formatdict, :indent)
                chunk.output = indent(chunk.output, formatdict[:indent])
            end
            strip(chunk.output) ≠ "" &&
                (result *= "$(formatdict[:outputstart])$(chunk.output)\n$(formatdict[:outputend])\n")
            strip(chunk.rich_output) ≠ "" && (result *= chunk.rich_output * "\n")
        end
    end

    end

    #Handle figures
    if chunk.options[:fig] && length(chunk.figures) > 0
        if chunk.options[:include]
            result *= formatfigures(chunk, docformat)
        end
    end

    return result
end

function format_output(result::AbstractString, docformat)
  return result
end

function format_output(result::AbstractString, docformat::JMarkdown2HTML)
  return Markdown.htmlesc(result)
end

function format_output(result::AbstractString, docformat::JMarkdown2tex)
  return uc2tex(result, true)
end

function format_code(result::AbstractString, docformat)
  return result
end

function format_code(result::AbstractString, docformat::JMarkdown2tex)
  highlighted = highlight(MIME("text/latex"), strip(result),
        Highlights.Lexers.JuliaLexer, docformat.formatdict[:theme])
  return uc2tex(highlighted)
  #return "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}\n$result\n\\end{minted}\n"
end

#Convert unicode to tex, escape listings if needed
function uc2tex(s, escape=false)
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

function format_code(result::AbstractString, docformat::JMarkdown2HTML)
  return highlight(MIME("text/html"), strip(result),
    Highlights.Lexers.JuliaLexer, docformat.formatdict[:theme])
end

function format_code(result::AbstractString, docformat::Pandoc2HTML)
    return highlight(MIME("text/html"), strip(result),
      Highlights.Lexers.JuliaLexer, docformat.formatdict[:theme])
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
        result = highlight(MIME("text/html"), strip(chunk.output),
          Highlights.Lexers.JuliaConsoleLexer, docformat.formatdict[:theme])
    else
        result = ""
    end
    return result
end

function format_termchunk(chunk, formatdict, docformat::Pandoc2HTML)
    if chunk.options[:echo] && chunk.options[:results] != "hidden"
        result = highlight(MIME("text/html"), strip(chunk.output),
          Highlights.Lexers.JuliaConsoleLexer, docformat.formatdict[:theme])
    else
        result = ""
    end
    return result
end

function format_termchunk(chunk, formatdict, docformat::JMarkdown2tex)
    if chunk.options[:echo] && chunk.options[:results] != "hidden"
        result = highlight(MIME("text/latex"), strip(chunk.output),
                  Highlights.Lexers.JuliaConsoleLexer,
                  docformat.formatdict[:theme])
        #return "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}\n$result\n\\end{minted}\n"
    else
        result = ""
    end
    return result
end

function indent(text, nindent)
    return join(map(x->
                    string(repeat(" ", nindent), x), split(text, "\n")), "\n")
end

function wraplines(text, line_width=75)
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

function wrapline(text, line_width=75)
    result = ""
    while length(text) > line_width
        result*= first(text, line_width) * "\n"
        text = chop(text, head=line_width, tail=0)
    end
    result *= text
end
