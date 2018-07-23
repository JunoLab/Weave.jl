import Mustache, Highlights
import .Markdown2HTML
using Compat
using Dates

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
        if contains(doc.doctype, "md2")
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

function stylesheet(m::MIME, theme)
  buf = PipeBuffer()
  Highlights.stylesheet(buf, m, theme)
  flush(buf)
  style = read(buf, String)
  close(buf)
  return style
end

function render_doc(formatted, doc::WeaveDoc, format::JMarkdown2HTML)
  css = stylesheet(MIME("text/html"), doc.highlight_theme)
  title, author, date = get_titleblock(doc)
  path, wsource = splitdir(abspath(doc.source))
  #wversion = string(Pkg.installed("Weave"))
  wversion = ""
  wtime =  string(Date(now()))

  if isempty(doc.css)
    theme_css = read(joinpath(dirname(@__FILE__), "../templates/skeleton_css.css"), String)
  else
    theme_css = read(doc.css, String)
  end

  if isempty(doc.template)
    template = Mustache.template_from_file(joinpath(dirname(@__FILE__), "../templates/julia_html.tpl"))
  else
    template = Mustache.template_from_file(doc.template)
  end

  return Mustache.render(template, themecss = theme_css,
                          highlightcss = css, body = formatted, header_script = doc.header_script,
                          source = wsource, wtime = wtime, wversion = wversion,
                          title = title, author = author, date = date)
end

function render_doc(formatted, doc::WeaveDoc, format::JMarkdown2tex)
  highlight = stylesheet(MIME("text/latex"), doc.highlight_theme)

  title, author, date = get_titleblock(doc)

  path, wsource = splitdir(abspath(doc.source))
  #wversion = string(Pkg.installed("Weave"))
  wversion = ""
  wtime =  string(Date(now()))

  if isempty(doc.template)
    template = Mustache.template_from_file(joinpath(dirname(@__FILE__), "../templates/julia_tex.tpl"))
  else
    template = Mustache.template_from_file(doc.template)
  end

  return Mustache.render(template, body = formatted,
    highlight = highlight,
    title = title, author = author, date = date)
end

function get_titleblock(doc::WeaveDoc)
  title = get!(doc.header, "title", false)
  author =  get!(doc.header, "author", false)
  date =  get!(doc.header, "date", false)
  return title, author, date
end

function strip_header(chunk::DocChunk)
  if occursin(r"^---$(?<header>.+)^---$"ms, chunk.content[1].content)
    chunk.content[1].content = lstrip(replace(chunk.content[1].content, r"^---$(?<header>.+)^---$"ms, ""))
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

function format_chunk(chunk::DocChunk, formatdict, docformat::JMarkdown2HTML)
    text = format_chunk(chunk, formatdict, nothing)
    #invokelatest seems to be needed here
    #to fix "invalid age range" on 0.6 #21653
    m = Compat.invokelatest(Base.Markdown.parse, text)

    return string(Markdown2HTML.html(m))
end



function format_chunk(chunk::DocChunk, formatdict, docformat::JMarkdown2tex)
    text = format_chunk(chunk, formatdict, nothing)
    m = Base.Markdown.parse(text)
    return Base.Markdown.latex(m)
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
  return(result)
end

function format_output(result::AbstractString, docformat::JMarkdown2HTML)
  return(Base.Markdown.htmlesc(result))
end

function format_code(result::AbstractString, docformat)
  return result
end

function format_code(result::AbstractString, docformat::JMarkdown2tex)
  #buf = PipeBuffer()
  #Highlights.highlight(buf, MIME("text/latex"), strip(result),
  #    Highlights.Lexers.JuliaLexer, docformat.formatdict[:theme])
  #flush(buf)
  #highlighted = readstring(buf)
  #close(buf)
  #return highlighted
  return "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}\n$result\n\\end{minted}\n"
end

function format_code(result::AbstractString, docformat::JMarkdown2HTML)
  buf = PipeBuffer()
  Highlights.highlight(buf, MIME("text/html"), strip(result),
    Highlights.Lexers.JuliaLexer, docformat.formatdict[:theme])
  flush(buf)
  highlighted = read(buf, String)
  close(buf)
  return highlighted
end

function format_code(result::AbstractString, docformat::Pandoc2HTML)
    buf = PipeBuffer()
    Highlights.highlight(buf, MIME("text/html"), strip(result),
      Highlights.Lexers.JuliaLexer, docformat.formatdict[:theme])
    flush(buf)
    highlighted = read(buf, String)
    close(buf)
    return highlighted
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
        buf = PipeBuffer()
        Highlights.highlight(buf, MIME("text/html"), strip(chunk.output), Highlights.Lexers.JuliaConsoleLexer)
        flush(buf)
        result = read(buf, String)
        close(buf)
    else
        result = ""
    end
    return result
end

function format_termchunk(chunk, formatdict, docformat::Pandoc2HTML)
    if chunk.options[:echo] && chunk.options[:results] != "hidden"
        buf = PipeBuffer()
        Highlights.highlight(buf, MIME("text/html"), strip(chunk.output), Highlights.Lexers.JuliaConsoleLexer)
        flush(buf)
        result = read(buf, String)
        close(buf)
    else
        result = ""
    end
    return result
end


function format_termchunk(chunk, formatdict, docformat::JMarkdown2tex)
    if chunk.options[:echo] && chunk.options[:results] != "hidden"
        #buf = PipeBuffer()
        #Highlights.highlight(buf, MIME("text/latex"), strip(chunk.output), Highlights.Lexers.JuliaConsoleLexer)
        #flush(buf)
        #result = readstring(buf)
        #close(buf)
        result = strip(chunk.output)
        return "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}\n$result\n\\end{minted}\n"
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

    #return result
    return strip(join(result, "\n"))
end

function wrapline(text, line_width=75)
result = ""
    while length(text) > line_width
        result*= text[1:line_width] * "\n"
        text = text[(line_width+1):end]
    end
result *= text
end
