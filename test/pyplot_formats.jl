using Weave
using Base.Test

weave("documents/pyplot_formats.txt", plotlib="pyplot", doctype="tex")
result = readall(open("documents/pyplot_formats.tex"))
ref = readall(open("documents/pyplot_formats_ref.tex"))
result = replace(result, r"\s*PyObject.*\n", "") #Remove PyObjects, because they change
ref = replace(ref, r"\s*PyObject.*\n", "")
@test result == ref

weave("documents/pyplot_formats.txt", plotlib="pyplot", doctype="github")
result = readall(open("documents/pyplot_formats.md"))
ref = readall(open("documents/pyplot_formats_ref.md"))
result = replace(result, r"\s*PyObject.*\n", "")
ref = replace(ref, r"\s*PyObject.*\n", "")
@test result == ref


weave("documents/pyplot_formats.txt", plotlib="pyplot", doctype="rst", fig_ext=".svg")
result = readall(open("documents/pyplot_formats.tex"))
ref = readall(open("documents/pyplot_formats_ref.tex"))
result = replace(result, r"\s*PyObject.*\n", "")
ref = replace(ref, r"\s*PyObject.*\n", "")
@test result == ref
