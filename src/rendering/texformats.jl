# Tex
# ---

abstract type LaTeXFormat <: WeaveFormat end

function set_format_options!(docformat::LaTeXFormat; keep_unicode = false, template = nothing, _kwargs...)
    docformat.keep_unicode |= keep_unicode
    docformat.template =
        get_mustache_template(isnothing(template) ? normpath(TEMPLATE_DIR, "md2pdf.tpl") : template)
end

# very similar to export to html
function render_chunk(docformat::LaTeXFormat, chunk::DocChunk)
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
    return unicode2latex(docformat, out)
end

render_output(docformat::LaTeXFormat, output) = unicode2latex(docformat, output, true)

render_code(docformat::LaTeXFormat, code) = unicode2latex(docformat, code, true)

render_termchunk(docformat::LaTeXFormat, chunk) =
    string(docformat.termstart,
            unicode2latex(docformat, chunk.output, true),
            docformat.termend, "\n")

# from julia symbols (e.g. "\bfhoge") to valid latex
const UNICODE2LATEX = let
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
    Dict(unicode => texify(sym) for (sym, unicode) in REPL.REPLCompletions.latex_symbols)
end

function unicode2latex(docformat::LaTeXFormat, s, escape = false)
    # Check whether to convert at all and return input if not
    docformat.keep_unicode && return s
    for (unicode, latex) in UNICODE2LATEX
        body = "\\ensuremath{$(latex)}"
        target = escape ? string(docformat.escape_starter, body, docformat.escape_closer) : body
        s = replace(s, unicode => target)
    end
    return s
end

function render_figures(docformat::LaTeXFormat, chunk)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    height = chunk.options[:out_height]
    f_pos = chunk.options[:fig_pos]
    f_env = chunk.options[:fig_env]
    result = ""
    figstring = ""

    if isnothing(f_env) && !isnothing(caption)
        f_env = "figure"
    end

    (isnothing(f_pos)) && (f_pos = "!h")
    # Set size
    attribs = ""
    isnothing(width) || (attribs = "width=$(md_length_to_latex(width,"\\linewidth"))")
    (!isempty(attribs) && !isnothing(height)) && (attribs *= ",")
    isnothing(height) || (attribs *= "height=$(md_length_to_latex(height,"\\paperheight"))")

    if !isnothing(f_env)
        result *= "\\begin{$f_env}"
        (!isempty(f_pos)) && (result *= "[$f_pos]")
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
    if !isnothing(caption)
        result *= string("\\center\n", "$figstring", "\\caption{$caption}\n")
    else
        result *= figstring
    end

    if !isnothing(chunk.options[:label]) && !isnothing(f_env)
        label = chunk.options[:label]
        result *= "\\label{fig:$label}\n"
    end

    if !isnothing(f_env)
        result *= "\\end{$f_env}\n"
    end

    return result
end

function md_length_to_latex(def, reference)
    if occursin("%", def)
        _def = tryparse(Float64, replace(def, "%" => ""))
        isnothing(_def) && return def
        perc = round(_def / 100, digits = 2)
        return "$perc$reference"
    end
    return def
end

function render_doc(docformat::LaTeXFormat, body, doc)
    return Mustache.render(
        docformat.template;
        body = body,
        highlight = "",
        tex_deps = docformat.tex_deps,
        [Pair(Symbol(k), v) for (k, v) in doc.header]...,
    )
end

# minted Tex
# ----------

Base.@kwdef mutable struct LaTeXMinted <: LaTeXFormat
    description = "LaTeX using minted package for code highlighting"
    extension = "tex"
    codestart = "\\begin{minted}[texcomments = true, mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}"
    codeend = "\\end{minted}"
    termstart = "\\begin{minted}[texcomments = true, mathescape, fontsize=\\footnotesize, xleftmargin=0.5em]{jlcon}"
    termend = "\\end{minted}"
    outputstart = "\\begin{minted}[texcomments = true, mathescape, fontsize=\\small, xleftmargin=0.5em, frame = leftline]{text}"
    outputend = "\\end{minted}"
    mimetypes = ["application/pdf", "image/png", "text/latex", "text/plain"]
    fig_ext = ".pdf"
    out_width = "\\linewidth"
    out_height = nothing
    fig_pos = "htpb"
    fig_env = "figure"
    # specials
    keep_unicode = false
    template = nothing
    tex_deps = "\\usepackage{minted}"
    # how to escape latex in verbatim/code environment
    escape_starter = "|\$"
    escape_closer = reverse(escape_starter)
end
register_format!("texminted", LaTeXMinted())

# Tex (directly to PDF)
# ---------------------

abstract type WeaveLaTeXFormat <: LaTeXFormat end

function set_format_options!(docformat::WeaveLaTeXFormat; template = nothing, highlight_theme = nothing, keep_unicode = false, _kwargs...)
    docformat.template =
        get_mustache_template(isnothing(template) ? normpath(TEMPLATE_DIR, "md2pdf.tpl") : template)
    docformat.highlight_theme = get_highlight_theme(highlight_theme)
    docformat.keep_unicode |= keep_unicode
end

function render_output(docformat::WeaveLaTeXFormat, output)
    # Highligts has some extra escaping defined, eg of $, ", ...
    output_escaped = sprint(
        (io, x) ->
            Highlights.Format.escape(io, MIME("text/latex"), x, charescape = true),
        output,
    )
    return unicode2latex(docformat, output_escaped, true)
end

function render_code(docformat::WeaveLaTeXFormat, code)
    ret = highlight_code(MIME("text/latex"), code, docformat.highlight_theme)
    unicode2latex(docformat, ret, false)
end

function render_termchunk(docformat::WeaveLaTeXFormat, chunk)
    if should_render(chunk)
        ret = highlight_term(MIME("text/latex"), chunk.output, docformat.highlight_theme)
        unicode2latex(docformat, ret, true)
    else
        ""
    end
end

function render_doc(docformat::WeaveLaTeXFormat, body, doc)
    return Mustache.render(
        docformat.template;
        body = body,
        highlight = get_highlight_stylesheet(MIME("text/latex"), docformat.highlight_theme),
        tex_deps = docformat.tex_deps,
        [Pair(Symbol(k), v) for (k, v) in doc.header]...,
    )
end

Base.@kwdef mutable struct WeaveLaTeX <: WeaveLaTeXFormat
    description = "Weave-styled LaTeX"
    extension = "tex"
    codestart = ""
    codeend = ""
    termstart = codestart
    termend = codeend
    outputstart = "\\begin{lstlisting}"
    outputend = "\\end{lstlisting}\n"
    mimetypes = ["application/pdf", "image/png", "image/jpg", "text/latex", "text/markdown", "text/plain"]
    fig_ext = ".pdf"
    out_width = "\\linewidth"
    out_height = nothing
    fig_pos = nothing
    fig_env = nothing
    # specials
    highlight_theme = nothing
    template = nothing
    keep_unicode = false
    tex_deps = ""
    # how to escape latex in verbatim/code environment
    escape_starter = "(*@"
    escape_closer = "@*)"
end
register_format!("md2tex", WeaveLaTeX())

# will be used by `write_doc`
const DEFAULT_LATEX_CMD = ["xelatex", "-shell-escape", "-halt-on-error"]


Base.@kwdef mutable struct LaTeX2PDF <: ExportFormat
    primaryformat = WeaveLaTeX()
    description = "PDF via LaTeX"
    latex_cmd = DEFAULT_LATEX_CMD
end
register_format!("md2pdf", LaTeX2PDF())
register_format!("minted2pdf", LaTeX2PDF(primaryformat=LaTeXMinted()))

function set_format_options!(docformat::LaTeX2PDF; latex_cmd = DEFAULT_LATEX_CMD, _kwargs...)
    docformat.latex_cmd = latex_cmd
    set_format_options!(docformat.primaryformat; _kwargs...)
end
