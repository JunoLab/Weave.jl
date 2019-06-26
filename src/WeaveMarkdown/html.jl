#module Markdown2HTML
# Markdown to HTML writer, Modified from Julia Base.Markdown html writer
using Markdown: MD, Header, Code, Paragraph, BlockQuote, Footnote, Table,
      Admonition, List, HorizontalRule, Bold, Italic, Image, Link, LineBreak,
      LaTeX, isordered

function tohtml(io::IO, m::MIME"text/html", x)
    show(io, m, x)
end

function tohtml(io::IO, m::MIME"text/plain", x)
    htmlesc(io, sprint(show, m, x))
end

function tohtml(io::IO, m::MIME"image/png", img)
    print(io, """<img src="data:image/png;base64,""")
    print(io, stringmime(m, img))
    print(io, "\" />")
end

function tohtml(m::MIME"image/svg+xml", img)
    show(io, m, img)
end



# AbstractDisplay infrastructure

function bestmime(val)
    for mime in ("text/html", "image/svg+xml", "image/png", "text/plain")
        showable(mime, val) && return MIME(Symbol(mime))
    end
    error("Cannot render $val to Markdown.")
end

tohtml(io::IO, x) = tohtml(io, bestmime(x), x)


# Utils

function withtag(f, io::IO, tag, attrs...)
    print(io, "<$tag")
    for (attr, value) in attrs
        print(io, " ")
        htmlesc(io, attr)
        print(io, "=\"")
        htmlesc(io, value)
        print(io, "\"")
    end
    f === nothing && return print(io, " />")

    print(io, ">")
    f()
    print(io, "</$tag>")
end

tag(io::IO, tag, attrs...) = withtag(nothing, io, tag, attrs...)

const _htmlescape_chars = Dict('<'=>"&lt;",   '>'=>"&gt;",
                               '"'=>"&quot;", '&'=>"&amp;",
                               # ' '=>"&nbsp;",
                               )
for ch in "'`!\$%()=+{}[]"
    _htmlescape_chars[ch] = "&#$(Int(ch));"
end

function htmlesc(io::IO, s::AbstractString)
    # s1 = replace(s, r"&(?!(\w+|\#\d+);)" => "&amp;")
    for ch in s
        print(io, get(_htmlescape_chars, ch, ch))
    end
end
function htmlesc(io::IO, s::Symbol)
    htmlesc(io, string(s))
end
function htmlesc(io::IO, xs::Union{AbstractString,Symbol}...)
    for s in xs
        htmlesc(io, s)
    end
end
function htmlesc(s::Union{AbstractString,Symbol})
    sprint(htmlesc, s)
end

# Block elements

function html(io::IO, content::Vector)
    for md in content
        html(io, md)
        println(io)
    end
end

html(io::IO, md::MD) = html(io, md.content)

function html(io::IO, header::Header{l}) where l
    withtag(io, "h$l") do
        htmlinline(io, header.text)
    end
end

function html(io::IO, code::Code)
    withtag(io, :pre) do
        maybe_lang = !isempty(code.language) ? Any[:class=>"language-$(code.language)"] : []
        withtag(io, :code, maybe_lang...) do
            htmlesc(io, code.code)
            # TODO should print newline if this is longer than one line ?
        end
    end
end

function html(io::IO, md::Paragraph)
    withtag(io, :p) do
        htmlinline(io, md.content)
    end
end

function html(io::IO, md::BlockQuote)
    withtag(io, :blockquote) do
        println(io)
        html(io, md.content)
    end
end

function html(io::IO, f::Footnote)
    withtag(io, :div, :class => "footnote", :id => "footnote-$(f.id)") do
        withtag(io, :p, :class => "footnote-title") do
            print(io, f.id)
        end
        html(io, f.text)
    end
end

function html(io::IO, md::Admonition)
    withtag(io, :div, :class => "admonition $(md.category)") do
        withtag(io, :p, :class => "admonition-title") do
            print(io, md.title)
        end
        html(io, md.content)
    end
end

function html(io::IO, md::List)
    maybe_attr = md.ordered > 1 ? Any[:start => string(md.ordered)] : []
    withtag(io, isordered(md) ? :ol : :ul, maybe_attr...) do
        for item in md.items
            println(io)
            withtag(io, :li) do
                html(io, item)
            end
        end
        println(io)
    end
end

function html(io::IO, md::HorizontalRule)
    tag(io, :hr)
end

function html(io::IO, tex::LaTeX)
    withtag(io, :p, :class => "math") do
        write(io, string("\\[\n", tex.formula, "\n\\]"))
    end
end

function html(io::IO, comment::Comment)
    write(io, "\n<!-- $(comment.text) -->\n")
end

function html(io::IO, md::Table)
    withtag(io, :table) do
        for (i, row) in enumerate(md.rows)
            withtag(io, :tr) do
                for c in md.rows[i]
                    withtag(io, i == 1 ? :th : :td) do
                        htmlinline(io, c)
                    end
                end
            end
        end
    end
end

html(io::IO, x) = tohtml(io, x)

# Inline elements

function htmlinline(io::IO, content::Vector)
    for x in content
        htmlinline(io, x)
    end
end

function htmlinline(io::IO, code::Code)
    withtag(io, :code) do
        htmlesc(io, code.code)
    end
end

function htmlinline(io::IO, tex::LaTeX)
    withtag(io, :span, :class => "math") do
        write(io, string("\$", tex.formula, "\$"))
    end
end

function htmlinline(io::IO, md::Union{Symbol,AbstractString})
    htmlesc(io, md)
end

function htmlinline(io::IO, md::Bold)
    withtag(io, :strong) do
        htmlinline(io, md.text)
    end
end

function htmlinline(io::IO, md::Italic)
    withtag(io, :em) do
        htmlinline(io, md.text)
    end
end

function htmlinline(io::IO, md::Image)
    tag(io, :img, :src=>md.url, :alt=>md.alt)
end


function htmlinline(io::IO, f::Footnote)
    withtag(io, :a, :href => "#footnote-$(f.id)", :class => "footnote") do
        print(io, "[", f.id, "]")
    end
end

function htmlinline(io::IO, link::Link)
    withtag(io, :a, :href=>link.url) do
        htmlinline(io, link.text)
    end
end

function htmlinline(io::IO, br::LineBreak)
    tag(io, :br)
end

function htmlinline(io::IO, comment::Comment)
    write(io, "<!-- $(comment.text) -->")
end

htmlinline(io::IO, x) = tohtml(io, x)

# API

html(md) = sprint(html, md)

#end
