# TODO: reorganize this file into multiple files corresponding to each output format

using Mustache, Highlights, .WeaveMarkdown, Markdown, Dates, Pkg
using REPL.REPLCompletions: latex_symbols

function format(doc, template = nothing, highlight_theme = nothing; css = nothing)
    docformat = doc.format

    # This could instead be made defaults in Base.@kwdef type declaration
    # Complete format dictionaries with defaults
    get!(docformat.formatdict, :termstart, docformat.formatdict[:codestart])
    get!(docformat.formatdict, :termend, docformat.formatdict[:codeend])
    get!(docformat.formatdict, :out_width, nothing)
    get!(docformat.formatdict, :out_height, nothing)
    get!(docformat.formatdict, :fig_pos, nothing)
    get!(docformat.formatdict, :fig_env, nothing)
    docformat.formatdict[:highlight_theme] = get_highlight_theme(highlight_theme)

    restore_header!(doc)

    lines = map(copy(doc.chunks)) do chunk
        format_chunk(chunk, docformat)
    end
    body = join(lines, '\n')

    return render_doc(docformat, body, doc, template, css, highlight_theme)
end

render_doc(_, body, args...) = body


get_highlight_theme(::Nothing) = Highlights.Themes.DefaultTheme
get_highlight_theme(highlight_theme::Type{<:Highlights.AbstractTheme}) = highlight_theme

get_html_template(::Nothing) = get_template(normpath(TEMPLATE_DIR, "md2html.tpl"))
get_html_template(x) = get_template(x)
get_tex_template(::Nothing) = get_template(normpath(TEMPLATE_DIR, "md2pdf.tpl"))
get_tex_template(x) = get_template(x)
get_template(path::AbstractString) = Mustache.template_from_file(path)
get_template(tpl::Mustache.MustacheTokens) = tpl

get_stylesheet(::Nothing) = get_stylesheet(normpath(STYLESHEET_DIR, "skeleton.css"))
get_stylesheet(path::AbstractString) = read(path, String)

get_highlight_stylesheet(mime, highlight_theme) =
    get_highlight_stylesheet(mime, get_highlight_theme(highlight_theme))
get_highlight_stylesheet(mime, highlight_theme::Type{<:Highlights.AbstractTheme}) =
    sprint((io, x) -> Highlights.stylesheet(io, mime, x), highlight_theme)
