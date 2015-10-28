#Test for Gadfly with different chunk options and figure formats
using Weave
using Base.Test

cleanup = true

weave("documents/gadfly_formats_test.txt", "tex")
result = readall(open("documents/gadfly_formats_test.tex"))
ref = readall(open("documents/gadfly_formats_test_ref.tex"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="tex", fig_ext=".tex", plotlib="gadfly")
result = readall(open("documents/gadfly_formats_test.tex"))
ref = readall(open("documents/gadfly_formats_test_tikz_ref.tex"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="tex", fig_ext=".ps", plotlib="gadfly")
result = readall(open("documents/gadfly_formats_test.tex"))
ref = readall(open("documents/gadfly_formats_test_ps_ref.tex"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="pandoc", plotlib="gadfly")
result = readall(open("documents/gadfly_formats_test.md"))
ref = readall(open("documents/gadfly_formats_test_pandoc_ref.md"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="pandoc", plotlib="gadfly", fig_ext=".svg")
result = readall(open("documents/gadfly_formats_test.md"))
ref = readall(open("documents/gadfly_formats_test_svg_ref.md"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="github", plotlib="gadfly", fig_ext=".js.svg")
result = readall(open("documents/gadfly_formats_test.md"))
ref = readall(open("documents/gadfly_formats_test_jssvg_ref.md"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="rst", plotlib="gadfly")
result = readall(open("documents/gadfly_formats_test.rst"))
ref = readall(open("documents/gadfly_formats_test_ref.rst"))
@test result == ref

weave("documents/gadfly_formats_test.txt", doctype="asciidoc", plotlib="gadfly",
    out_path="documents/output")
result = readall(open("documents/output/gadfly_formats_test.txt"))
ref = readall(open("documents/output/gadfly_formats_test_ref.txt"))
@test result == ref

weave("documents/gadfly_markdown_test.jmd", doctype="github",plotlib="gadfly", informat="markdown")
result = readall(open("documents/gadfly_markdown_test.md"))
ref = readall(open("documents/gadfly_markdown_test_ref.md"))
@test result == ref

if cleanup
    rm("documents/gadfly_formats_test.tex")
    rm("documents/gadfly_formats_test.txt")
    rm("documents/gadfly_formats_test.rst")
    rm("documents/gadfly_markdown_test.md")
    rm("documents/output", recursive = true)
    rm("documents/figures", recursive = true)
end
