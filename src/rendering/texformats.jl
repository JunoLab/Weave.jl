# PDF and Tex
# -----------

abstract type TexFormat <: WeaveFormat end

Base.@kwdef mutable struct JMarkdown2tex <: TexFormat
    description = "Julia markdown to latex"
    codestart = ""
    codeend = ""
    outputstart = "\\begin{lstlisting}"
    outputend = "\\end{lstlisting}\n"
    fig_ext = ".pdf"
    extension = "tex"
    mimetypes = ["application/pdf", "image/png", "image/jpg",
        "text/latex", "text/markdown", "text/plain"]
    keep_unicode = false
    termstart = codestart
    termend = codeend
    out_width = "\\linewidth"
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    highlight_theme = nothing
    template = normpath(TEMPLATE_DIR, "md2pdf.tpl")
    tex_deps = ""
end
register_format!("md2tex", JMarkdown2tex())
register_format!("md2pdf", JMarkdown2tex())

Base.@kwdef mutable struct Tex <: TexFormat
    description = "Latex with custom code environments"
    codestart = "\\begin{juliacode}"
    codeend = "\\end{juliacode}"
    outputstart = "\\begin{juliaout}"
    outputend = "\\end{juliaout}"
    termstart = "\\begin{juliaterm}"
    termend = "\\end{juliaterm}"
    fig_ext = ".pdf"
    extension = "tex"
    fig_env = "figure"
    fig_pos = "htpb"
    mimetypes = ["application/pdf", "image/png", "text/latex", "text/plain"]
    keep_unicode = false
    out_width = "\\linewidth"
    out_height = nothing
    highlight_theme = nothing
    template = normpath(TEMPLATE_DIR, "md2pdf.tpl")
    tex_deps = ""
end
register_format!("tex", Tex())

Base.@kwdef mutable struct TexMinted <: TexFormat
    description = "Latex using minted for highlighting"
    codestart =
        "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}"
    codeend = "\\end{minted}"
    outputstart =
    "\\begin{minted}[fontsize=\\small, xleftmargin=0.5em, mathescape, frame = leftline]{text}"
    outputend = "\\end{minted}"
    fig_ext = ".pdf"
    extension = "tex"
    mimetypes = ["application/pdf", "image/png", "text/latex", "text/plain"]
    keep_unicode = false
    termstart =
    "\\begin{minted}[fontsize=\\footnotesize, xleftmargin=0.5em, mathescape]{jlcon}"
    termend = "\\end{minted}"
    out_width = "\\linewidth"
    out_height = nothing
    fig_env = "figure"
    fig_pos = "htpb"
    highlight_theme = nothing
    template = normpath(TEMPLATE_DIR, "md2pdf.tpl")
    tex_deps = "\\usepackage{minted}"
end
register_format!("texminted", TexMinted())


highlight_str(docformat::TexFormat) = ""
highlight_str(docformat::JMarkdown2tex) =
    get_highlight_stylesheet(MIME("text/latex"), docformat.highlight_theme)

function render_doc(docformat::TexFormat, body, doc, _)
    return Mustache.render(
        get_tex_template(docformat.template);
        body = body,
        highlight = highlight_str(docformat),
        tex_deps = docformat.tex_deps,
        [Pair(Symbol(k), v) for (k, v) in doc.header]...,
    )
end

# very similar to export to html
function format_chunk(chunk::DocChunk, docformat::TexFormat)
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
    return docformat.keep_unicode ? out : uc2tex(out)
end

function format_output(result, docformat::TexFormat)
    # Highligts has some extra escaping defined, eg of $, ", ...
    result_escaped = sprint(
        (io, x) ->
            Highlights.Format.escape(io, MIME("text/latex"), x, charescape = true),
        result,
    )
    docformat.keep_unicode || return uc2tex(result_escaped, true)
    return result_escaped
end


# Highlight code is currently only compatible with lstlistings (JMarkdown2tex)
highlight_code(code, docformat::TexFormat) = code
highlight_code(code, docformat::JMarkdown2tex) =
    highlight_code(MIME("text/latex"), code, docformat.highlight_theme)

function format_code(code, docformat::TexFormat)
    ret = highlight_code(code, docformat)
    docformat.keep_unicode || return uc2tex(ret)
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


# return "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}\n$result\n\\end{minted}\n"
format_termchunk(chunk, docformat::TexFormat) =
    string(docformat.termstart, chunk.output, docformat.termend, '\n')

    #should_render(chunk) ? highlight_term(MIME("text/latex"), , docformat.highlight_theme) : ""
format_termchunk(chunk, docformat::JMarkdown2tex) =
    should_render(chunk) ? highlight_term(MIME("text/latex"), chunk.output, docformat.highlight_theme) : ""


function formatfigures(chunk, docformat::TexFormat)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    height = chunk.options[:out_height]
    f_pos = chunk.options[:fig_pos]
    f_env = chunk.options[:fig_env]
    result = ""
    figstring = ""

    if f_env == nothing && caption != nothing
        f_env = "figure"
    end

    (f_pos == nothing) && (f_pos = "!h")
    # Set size
    attribs = ""
    width == nothing || (attribs = "width=$(md_length_to_latex(width,"\\linewidth"))")
    (attribs != "" && height != nothing) && (attribs *= ",")
    height == nothing || (attribs *= "height=$(md_length_to_latex(height,"\\paperheight"))")

    if f_env != nothing
        result *= "\\begin{$f_env}"
        (f_pos != "") && (result *= "[$f_pos]")
        result *= "\n"
    end

    for fig in fignames
        if splitext(fig)[2] == ".tex" # Tikz figures
            figstring *= "\\resizebox{$width}{!}{\\input{$fig}}\n"
        else
            if isempty(attribs)
                figstring *= "\\includegraphics{$fig}\n"
            else
                figstring *= "\\includegraphics[$attribs]{$fig}\n"
            end
        end
    end

    # Figure environment
    if caption != nothing
        result *= string("\\center\n", "$figstring", "\\caption{$caption}\n")
    else
        result *= figstring
    end

    if chunk.options[:label] != nothing && f_env != nothing
        label = chunk.options[:label]
        result *= "\\label{fig:$label}\n"
    end

    if f_env != nothing
        result *= "\\end{$f_env}\n"
    end

    return result
end


function md_length_to_latex(def, reference)
    if occursin("%", def)
        _def = tryparse(Float64, replace(def, "%" => ""))
        _def == nothing && return def
        perc = round(_def / 100, digits = 2)
        return "$perc$reference"
    end
    return def
end
