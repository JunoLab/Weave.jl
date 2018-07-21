using Weave
using Test

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
f_check = "<h1>Test chunk</h1>\n<p>Test rendering <span class=\"math\">\$\alpha\$</span></p>\n"
f = Weave.format_chunk(dchunk, docformat.formatdict, docformat)
@test f_check == f

# Test with actual doc

parsed = Weave.read_doc("documents/chunk_options.noweb")
doc = Weave.run(parsed, doctype = "md2html")

c_check = "<pre class='hljl'>\n<span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-p'>[</span><span class='hljl-ni'>12</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>10</span><span class='hljl-p'>]</span><span class='hljl-t'>\n</span><span class='hljl-nf'>println</span><span class='hljl-p'>(</span><span class='hljl-n'>y</span><span class='hljl-p'>)</span>\n</pre>\n"
doc.format.formatdict[:theme] = doc.highlight_theme
c = Weave.format_code(doc.chunks[3].content, doc.format)
@test c_check == c

o_check = "\nprintln&#40;x&#41;\n"
o = Weave.format_output(doc.chunks[4].content, doc.format)
@test o_check == o

doc.template = "templates/mini.tpl"
rendered = Weave.render_doc("Hello", doc, doc.format)
@test rendered == "\nHello\n"

# Tex format
parsed = Weave.read_doc("documents/chunk_options.noweb")
doc = Weave.run(parsed, doctype = "md2tex")

c_check = "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}\n\nprintln(x)\n\n\\end{minted}\n"
doc.format.formatdict[:theme] = doc.highlight_theme
c = Weave.format_code(doc.chunks[4].content, doc.format)
@test c_check == c

o_check = "\nx = [12, 10]\nprintln(y)\n"
o = Weave.format_output(doc.chunks[3].content, doc.format)
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
@test htext.content[1].content == h_ref
