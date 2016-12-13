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

parsed = Weave.read_doc("documents/chunk_options.noweb")
doc = Weave.run(parsed, doctype = "md2html")
title = Weave.get_title(doc)
@test title == "documents/chunk_options.noweb"

c_check = "<pre class='hljl'>\n<span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-p'>[</span><span class='hljl-ni'>12</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>10</span><span class='hljl-p'>]</span><span class='hljl-t'>\n</span><span class='hljl-nf'>println</span><span class='hljl-p'>(</span><span class='hljl-n'>y</span><span class='hljl-p'>)</span>\n</pre>\n"
c = Weave.format_code(doc.chunks[4].content, doc.format)
@test c_check == c

o_check = "\nx &#61; &#91;12, 10&#93;\nprintln&#40;y&#41;\n"
o = Weave.format_output(doc.chunks[4].content, doc.format)
@test o_check == o
