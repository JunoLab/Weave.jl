using Weave, Compat
using Base.Test

weave("documents/winston_formats.txt", plotlib="Winston", doctype="tex")
result = @compat readstring(open("documents/winston_formats.tex"))
ref = @compat readstring(open("documents/winston_formats_ref.tex"))
@test result == ref


weave("documents/winston_formats.txt", plotlib="Winston", doctype="github")
result = @compat readstring(open("documents/winston_formats.md"))
ref = @compat readstring(open("documents/winston_formats_ref.md"))
@test result == ref

weave("documents/winston_formats.txt", plotlib="Winston", doctype="pandoc", fig_ext=".svg")
result = @compat readstring(open("documents/winston_formats.md"))
ref = @compat readstring(open("documents/winston_formats_svg_ref.md"))
@test result == ref

weave("documents/winston_formats.txt", plotlib="Winston", doctype="rst")
result = @compat readstring(open("documents/winston_formats.rst"))
ref = @compat readstring(open("documents/winston_formats_ref.rst"))
@test result == ref
