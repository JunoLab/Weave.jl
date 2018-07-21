using Weave
using Test

cleanup = true

weave("documents/pyplot_formats.txt", plotlib="pyplot", doctype="tex")
result =  read("documents/pyplot_formats.tex", String)
ref =  read("documents/pyplot_formats_ref.tex", String)
result = replace(result, r"\s*PyObject.*\n", "\n") #Remove PyObjects, because they change
ref = replace(ref, r"\s*PyObject.*\n", "\n")
@test result == ref

weave("documents/pyplot_formats.txt", plotlib="pyplot", doctype="github")
result =  read("documents/pyplot_formats.md", String)
ref =  read("documents/pyplot_formats_ref.md", String)
result = replace(result, r"\s*PyObject.*\n", "")
ref = replace(ref, r"\s*PyObject.*\n", "")
@test result == ref


weave("documents/pyplot_formats.txt", plotlib="pyplot", doctype="rst", fig_ext=".svg")
result =  read("documents/pyplot_formats.rst", String)
ref =  read("documents/pyplot_formats_ref.rst", String)
result = replace(result, r"\s*PyObject.*\n", "")
ref = replace(ref, r"\s*PyObject.*\n", "")
@test result == ref

if cleanup
    rm("documents/pyplot_formats.tex")
    rm("documents/pyplot_formats.rst")
    rm("documents/pyplot_formats.md")
    rm("documents/figures", recursive = true)
end
