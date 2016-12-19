using Weave
using Base.Test

# Test rendering of doc chunks
content = """
# Test chunk

Test rendering \$\alpha\$
"""

dchunk = Weave.DocChunk(content, 1, 1)

pformat = Weave.formats["github"]
f = Weave.format_chunk(dchunk, pformat.formatdict, pformat)
@test f == content

docformat = Weave.formats["md2html"]
f_check = "<div><h1>Test chunk</h1><p>Test rendering <span>\$\alpha\$</span></p></div>"
f = Weave.format_chunk(dchunk, docformat.formatdict, docformat)
@test f_check == f

# Test with actual doc

parsed = Weave.read_doc("documents/chunk_options.noweb")
doc = Weave.run(parsed, doctype = "md2html")

c_check = "<pre class='hljl'>\n<span class='hljl-nf'>println</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>)</span>\n</pre>\n"
doc.format.formatdict[:theme] = doc.highlight_theme
c = Weave.format_code(doc.chunks[3].content, doc.format)
@test c_check == c

o_check = "\nprintln&#40;x&#41;"
o = Weave.format_output(doc.chunks[3].content, doc.format)
@test o_check == o

doc.template = "templates/mini.tpl"
rendered = Weave.render_doc("Hello", doc, doc.format)
@test rendered == "\nHello\n"

# Tex format
parsed = Weave.read_doc("documents/chunk_options.noweb")
doc = Weave.run(parsed, doctype = "md2tex")

c_check = "\\begin{lstlisting}\n(*@\\HLJLnf{println}@*)(*@\\HLJLp{(}@*)(*@\\HLJLn{x}@*)(*@\\HLJLp{)}@*)\n\\end{lstlisting}\n"
doc.format.formatdict[:theme] = doc.highlight_theme
c = Weave.format_code(doc.chunks[3].content, doc.format)
@test c_check == c

o_check = "\nx = [12, 10]\nprintln(y)"
o = Weave.format_output(doc.chunks[2].content, doc.format)
@test o_check == o

doc.template = "templates/mini.tpl"
rendered = Weave.render_doc("Hello", doc, doc.format)
@test rendered == "\nHello\n"


# Test header parsing and stripping
header = """
---
title : Test block
author : Matti Pastell
---

# Actual header

and some text

"""

dchunk = Weave.DocChunk(header, 1, 1)
h = Weave.parse_header(dchunk)
h_ref = Dict("author" => "Matti Pastell", "title" => "Test block")
@test h_ref == h

htext = Weave.strip_header(dchunk)
h_ref = """
# Actual header

and some text

"""
@test htext.content == h_ref
