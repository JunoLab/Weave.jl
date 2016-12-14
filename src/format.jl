import Mustache, Highlights, Documenter

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

function stylesheet(m::MIME)
  buf = PipeBuffer()
  Highlights.stylesheet(buf, m)
  flush(buf)
  style = readstring(buf)
  close(buf)
  return style
end

function render_doc(formatted, doc::WeaveDoc, format::JMarkdown2HTML)
  css = stylesheet(MIME("text/html"))
  title = get_title(doc)
  path, wsource = splitdir(abspath(doc.source))
  wversion = string(Pkg.installed("Weave"))
  wtime =  string(Date(now()))

  theme_css = readstring(joinpath(dirname(@__FILE__), "../templates/skeleton_css.txt"))
  template = Mustache.template_from_file(joinpath(dirname(@__FILE__), "../templates/julia_html.txt"))

  return Mustache.render(template, themecss = theme_css,
                          highlightcss = css, body = formatted, header_script = doc.header_script,
                          source = wsource, wtime = wtime, wversion = wversion,
                          title = title)
end

function render_doc(formatted, doc::WeaveDoc, format::JMarkdown2tex)
  highlight = stylesheet(MIME("text/latex"))
  title = get_title(doc)
  path, wsource = splitdir(abspath(doc.source))
  wversion = string(Pkg.installed("Weave"))
  wtime =  string(Date(now()))
  template = Mustache.template_from_file(joinpath(dirname(@__FILE__), "../templates/julia_tex.txt"))

  return Mustache.render(template, body = formatted,
    highlight = highlight,
    title = title)
end


function get_title(doc::WeaveDoc)
  if isa(doc.chunks[1], CodeChunk)
    return doc.source
  end

  isempty(doc.chunks[1].content) && return doc.source
  m = Base.Markdown.parse(doc.chunks[1].content)

  if isa(m.content[1], Base.Markdown.Header)
      title = m.content[1].text[1]
  else
      title = doc.source
  end

  return title
end

function format_chunk(chunk::DocChunk, formatdict, docformat)
    return chunk.content
end

function format_chunk(chunk::DocChunk, formatdict, docformat::JMarkdown2HTML)
    m = Base.Markdown.parse(chunk.content)
    #Base.Markdown.html(m)
    return string(Documenter.Writers.HTMLWriter.mdconvert(m))
end

function Base.Markdown.latex(io::IO, md::Base.Markdown.Paragraph)
    println(io)
    for md in md.content
        Base.Markdown.latexinline(io, md)
    end
    println(io)
end


function format_chunk(chunk::DocChunk, formatdict, docformat::JMarkdown2tex)
    m = Base.Markdown.parse(chunk.content)
    #TODO add space between paragraphs
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
            result = "$(formatdict[:codestart])$(chunk.content)\n$(formatdict[:codeend])"
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
        result = "$(formatdict[:codestart])$(chunk.content)\n$(formatdict[:codeend])\n"
    else
        result = ""
    end

    if (strip(chunk.output)!= "" || strip(chunk.rich_output) != "") && (chunk.options[:results] != "hidden")
        chunk.output = format_output(chunk.output, docformat)
        if chunk.options[:results] != "markup" && chunk.options[:results] != "hold"
            strip(chunk.output) ≠ "" && (result *= "$(chunk.output)\n")
            strip(chunk.rich_output) ≠ "" && (result *= "$(chunk.rich_output)\n")
        else
            if chunk.options[:wrap]
                chunk.output = "\n" * wraplines(chunk.output,
                                        chunk.options[:line_width])
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
  buf = PipeBuffer()
  Highlights.highlight(buf, MIME("text/latex"), strip(result), Highlights.Lexers.JuliaLexer)
  flush(buf)
  highlighted = readstring(buf)
  close(buf)
  return highlighted
end

function format_code(result::AbstractString, docformat::JMarkdown2HTML)
  buf = PipeBuffer()
  Highlights.highlight(buf, MIME("text/html"), strip(result), Highlights.Lexers.JuliaLexer)
  flush(buf)
  highlighted = readstring(buf)
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
        result = readstring(buf)
        close(buf)
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
