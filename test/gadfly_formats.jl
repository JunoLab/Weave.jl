#Test for Gadfly with different chunk options and figure formats
using Weave
using Base.Test

weave("documents/gadfly_formats_test.txt", doctype="tex", plotlib="gadfly")
result = readall(open("documents/gadfly_formats_test.tex"))
ref = readall(open("documents/gadfly_formats_test_ref.tex"))
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
