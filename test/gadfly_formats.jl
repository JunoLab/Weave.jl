#Test for Gadfly with different chunk options and figure formatsusing Weave
using Weave
using Base.Test


weave("documents/gadfly_formats_test.txt", "tex")
result =  readstring(open("documents/gadfly_formats_test.tex"))
ref =  readstring(open("documents/gadfly_formats_test_ref.tex"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="tex", fig_ext=".tex", plotlib="gadfly")
result =  readstring(open("documents/gadfly_formats_test.tex"))
ref =  readstring(open("documents/gadfly_formats_test_tikz_ref.tex"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="tex", fig_ext=".ps", plotlib="gadfly")
result =  readstring(open("documents/gadfly_formats_test.tex"))
ref =  readstring(open("documents/gadfly_formats_test_ps_ref.tex"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="pandoc", plotlib="gadfly")
result =  readstring(open("documents/gadfly_formats_test.md"))
ref =  readstring(open("documents/gadfly_formats_test_pandoc_ref.md"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="pandoc", plotlib="gadfly", fig_ext=".svg")
result =  readstring(open("documents/gadfly_formats_test.md"))
ref =  readstring(open("documents/gadfly_formats_test_svg_ref.md"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="github", plotlib="gadfly", fig_ext=".js.svg")
result =  readstring(open("documents/gadfly_formats_test.md"))
ref =  readstring(open("documents/gadfly_formats_test_jssvg_ref.md"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="rst", plotlib="gadfly")
result =  readstring(open("documents/gadfly_formats_test.rst"))
ref =  readstring(open("documents/gadfly_formats_test_ref.rst"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="multimarkdown", plotlib="gadfly")
result =  readstring(open("documents/gadfly_formats_test.md"))
ref =  readstring(open("documents/gadfly_formats_test_mmd_ref.md"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="asciidoc", plotlib="gadfly",
    out_path="documents/output")
result =  readstring(open("documents/output/gadfly_formats_test.txt"))
ref =  readstring(open("documents/output/gadfly_formats_test_ref.txt"))
@test result == ref

weave("documents/gadfly_markdown_test.jmd", doctype="github",plotlib="gadfly", informat="markdown")
result =  readstring(open("documents/gadfly_markdown_test.md"))
ref =  readstring(open("documents/gadfly_markdown_test_ref.md"))
@test result == ref

weave("documents/FIR_design.jl", doctype="pandoc", plotlib="gadfly", informat="script")
result =  readstring(open("documents/FIR_design.md"))
ref =  readstring(open("documents/FIR_design_ref.md"))
@test result == ref
