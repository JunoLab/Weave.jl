using Weave
using Base.Test

weave("documents/winston_formats.txt", plotlib="Winston", doctype="tex")
result = readall(open("documents/winston_formats.tex"))
ref = readall(open("documents/winston_formats_ref.tex"))
@test result == ref


weave("documents/winston_formats.txt", plotlib="Winston", doctype="github")
result = readall(open("documents/winston_formats.md"))
ref = readall(open("documents/winston_formats_ref.md"))
@test result == ref

weave("documents/winston_formats.txt", plotlib="Winston", doctype="pandoc", fig_ext=".svg")
result = readall(open("documents/winston_formats.md"))
ref = readall(open("documents/winston_formats_svg_ref.md"))
@test result == ref

weave("documents/winston_formats.txt", plotlib="Winston", doctype="rst")
result = readall(open("documents/winston_formats.rst"))
ref = readall(open("documents/winston_formats_ref.rst"))
@test result == ref
