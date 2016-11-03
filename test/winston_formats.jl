using Weave, Compat
using Base.Test

weave("documents/winston_formats.txt", plotlib="Winston", doctype="tex")
result =  readstring(open("documents/winston_formats.tex"))
ref =  readstring(open("documents/winston_formats_ref.tex"))
@test result == ref


weave("documents/winston_formats.txt", plotlib="Winston", doctype="github")
result =  readstring(open("documents/winston_formats.md"))
ref =  readstring(open("documents/winston_formats_ref.md"))
@test result == ref

weave("documents/winston_formats.txt", plotlib="Winston", doctype="pandoc", fig_ext=".svg")
result =  readstring(open("documents/winston_formats.md"))
ref =  readstring(open("documents/winston_formats_svg_ref.md"))
@test result == ref

weave("documents/winston_formats.txt", plotlib="Winston", doctype="rst")
result =  readstring(open("documents/winston_formats.rst"))
ref =  readstring(open("documents/winston_formats_ref.rst"))
@test result == ref
