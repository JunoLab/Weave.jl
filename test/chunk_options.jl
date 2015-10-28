using Weave
using Base.Test

cleanup = true

#Test chunk options and output formats
weave("documents/chunk_options.noweb", plotlib=nothing)
result = readall(open("documents/chunk_options.md"))
ref = readall(open("documents/chunk_options_ref.md"))
@test result == ref
cleanup && rm("documents/chunk_options.md")

weave("documents/chunk_options.noweb", doctype="tex", plotlib=nothing)
result = readall(open("documents/chunk_options.tex"))
ref = readall(open("documents/chunk_options_ref.tex"))
@test result == ref
cleanup && rm("documents/chunk_options.tex")

weave("documents/chunk_options.noweb", doctype="texminted", plotlib=nothing)
result = readall(open("documents/chunk_options.tex"))
ref = readall(open("documents/chunk_options_ref.texminted"))
@test result == ref
cleanup && rm("documents/chunk_options.tex")

weave("documents/chunk_options.noweb", doctype="rst", plotlib=nothing)
result = readall(open("documents/chunk_options.rst"))
ref = readall(open("documents/chunk_options_ref.rst"))
@test result == ref
cleanup && rm("documents/chunk_options.rst")

tangle("documents/chunk_options.noweb")
result = readall(open("documents/chunk_options.jl"))
ref = readall(open("documents/chunk_options_ref.jl"))
@test result == ref
cleanup && rm("documents/chunk_options.jl")

#Test chunk options and output formats
weave("documents/chunk_func.noweb", plotlib=nothing)
result = readall(open("documents/chunk_func.md"))
ref = readall(open("documents/chunk_func_ref.md"))
@test result == ref
cleanup && rm("documents/chunk_func.md")
