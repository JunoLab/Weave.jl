# Test disable escaping of unicode
@testset "escape/unescape unicode characters" begin

content = """
# Test chunk
α
"""
chunk = Weave.DocChunk(content, 1, 1)
fmt = deepcopy(Weave.FORMATS["md2tex"])

f = Weave.format_chunk(chunk, fmt)
@test f == "\\section{Test chunk}\n\\ensuremath{\\alpha}\n\n"

fmt.keep_unicode = true
f = Weave.format_chunk(chunk, fmt)
@test f == "\\section{Test chunk}\nα\n\n"


str = """
```julia
α = 10
```
"""
doc = mock_run(str; doctype = "md2tex")
Weave.set_rendering_options!(doc.format)
doc = Weave.render_doc(doc)
@test occursin(Weave.uc2tex("α"), doc)
@test !occursin("α", doc)

doc = mock_run(str; doctype = "md2tex")
Weave.set_rendering_options!(doc.format; keep_unicode = true)
doc = Weave.render_doc(doc)
@test occursin("α", doc)
@test !occursin(Weave.uc2tex("α"), doc)

end
