using Weave, Test
using Mustache

# Test parsing

doc = """

! println("Something")

Some markdown with inline stuff and `j code`

 ! Not julia code but `j show("is")`

"""

pat = Weave.input_formats["markdown"].inline
ms = collect(eachmatch(pat, doc))
@test ms[1][2] == "println(\"Something\")"
@test ms[2][1] == "code"
@test ms[3][1] == "show(\"is\")"

chunk = Weave.parse_doc(doc, Weave.input_formats["markdown"])[1]
@test length(chunk.content) == 7
@test chunk.content[2].content == ms[1][2]
@test chunk.content[4].content == ms[2][1]
@test chunk.content[6].content == ms[3][1]

chunknw = Weave.parse_doc(doc, Weave.input_formats["noweb"])[1]
@test all([chunknw.content[i].content == chunk.content[i].content for i in 1:7])

# Test with document

tpl = mt"""
{{{ :body }}}
"""

out = weave(joinpath(@__DIR__, "documents", "markdown_beamer.jmd"), doctype="md2html", template=tpl)
@test read(out, String) == read(out*".ref", String)
rm(out)

out = weave(joinpath(@__DIR__, "documents", "markdown_beamer.jmd"), doctype="md2tex", template=tpl)
@test read(out, String) == read(out*".ref", String)
rm(out)
