# TODO:
# - 1. Improve argument handling
# - 2. Update code to use UnPack.jl to make it more readable
# - 3. Export new interface
# - 4. Document Interface

using Mustache, Highlights, .WeaveMarkdown, Markdown, Dates, Pkg
using REPL.REPLCompletions: latex_symbols


const FORMATS = Dict{String,WeaveFormat}()

# TODO: do some assertion for necessary fields of `format`
register_format!(format_name::AbstractString, format::WeaveFormat) = push!(FORMATS, format_name => format)
register_format!(_,format) = error("Format needs to be a subtype of WeaveFormat.")

function format(doc; css = nothing)
    docformat = doc.format

    restore_header!(doc)

    lines = map(copy(doc.chunks)) do chunk
        format_chunk(chunk, docformat)
    end
    body = join(lines, '\n')

    return render_doc(docformat, body, doc, css)
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


include("common.jl")
include("htmlformats.jl")
include("texformats.jl")
include("variousformats.jl")
include("markdownformats.jl")
