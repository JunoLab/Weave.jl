using Weave, Compat
using Base.Test

cleanup = true

weave("documents/pyplot_formats.txt", plotlib="pyplot", doctype="tex")
result =  readstring(open("documents/pyplot_formats.tex"))
ref =  readstring(open("documents/pyplot_formats_ref.tex"))
result = replace(result, r"\s*PyObject.*\n", "\n") #Remove PyObjects, because they change
ref = replace(ref, r"\s*PyObject.*\n", "\n")
@test result == ref

weave("documents/pyplot_formats.txt", plotlib="pyplot", doctype="github")
result =  readstring(open("documents/pyplot_formats.md"))
ref =  readstring(open("documents/pyplot_formats_ref.md"))
result = replace(result, r"\s*PyObject.*\n", "")
ref = replace(ref, r"\s*PyObject.*\n", "")
@test result == ref


weave("documents/pyplot_formats.txt", plotlib="pyplot", doctype="rst", fig_ext=".svg")
result =  readstring(open("documents/pyplot_formats.rst"))
ref =  readstring(open("documents/pyplot_formats_ref.rst"))
result = replace(result, r"\s*PyObject.*\n", "")
ref = replace(ref, r"\s*PyObject.*\n", "")
@test result == ref

if cleanup
    rm("documents/pyplot_formats.tex")
    rm("documents/pyplot_formats.rst")
    rm("documents/pyplot_formats.md")
    rm("documents/figures", recursive = true)
end
