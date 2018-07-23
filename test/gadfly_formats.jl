#Test for Gadfly with different chunk options and figure formatsusing Weave
using Weave
using Test


weave("documents/gadfly_formats_test.txt", doctype = "tex", plotlib="gadfly")
result =  read("documents/gadfly_formats_test.tex", String)
ref =  read("documents/gadfly_formats_test_ref.tex", String)
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="tex", fig_ext=".tex", plotlib="gadfly")
result =  read("documents/gadfly_formats_test.tex", String)
ref =  read("documents/gadfly_formats_test_tikz_ref.tex", String)
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="tex", fig_ext=".ps", plotlib="gadfly")
result =  read("documents/gadfly_formats_test.tex", String)
ref =  read("documents/gadfly_formats_test_ps_ref.tex", String)
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="pandoc", plotlib="gadfly")
result =  read("documents/gadfly_formats_test.md", String)
ref =  read("documents/gadfly_formats_test_pandoc_ref.md", String)
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="pandoc", plotlib="gadfly", fig_ext=".svg")
result =  read("documents/gadfly_formats_test.md", String)
ref =  read("documents/gadfly_formats_test_svg_ref.md", String)
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="github", plotlib="gadfly", fig_ext=".js.svg")
result =  read("documents/gadfly_formats_test.md", String)
ref =  read("documents/gadfly_formats_test_jssvg_ref.md", String)
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="rst", plotlib="gadfly")
result =  read("documents/gadfly_formats_test.rst", String)
ref =  read("documents/gadfly_formats_test_ref.rst", String)
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="multimarkdown", plotlib="gadfly")
result =  read("documents/gadfly_formats_test.md", String)
ref =  read("documents/gadfly_formats_test_mmd_ref.md", String)
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="asciidoc", plotlib="gadfly",
    out_path="documents/output")
result =  read("documents/output/gadfly_formats_test.txt", String)
ref =  read("documents/output/gadfly_formats_test_ref.txt", String)
@test result == ref

weave("documents/gadfly_markdown_test.jmd", doctype="github",plotlib="gadfly", informat="markdown")
result =  read("documents/gadfly_markdown_test.md", String)
ref =  read("documents/gadfly_markdown_test_ref.md", String)
@test result == ref

weave("documents/FIR_design.jl", doctype="pandoc", plotlib="gadfly", informat="script")
result =  read("documents/FIR_design.md", String)
ref =  read("documents/FIR_design_ref.md", String)
@test result == ref
