using Weave
using Base.Test

#Test chunk options and output formats
weave("documents/chunk_options.noweb", plotlib=nothing)
result = readall(open("documents/chunk_options.md"))
ref = readall(open("documents/chunk_options_ref.md"))
@test result == ref

weave("documents/chunk_options.noweb", doctype="tex", plotlib=nothing)
result = readall(open("documents/chunk_options.tex"))
ref = readall(open("documents/chunk_options_ref.tex"))
@test result == ref

weave("documents/chunk_options.noweb", doctype="texminted", plotlib=nothing)
result = readall(open("documents/chunk_options.tex"))
ref = readall(open("documents/chunk_options_ref.texminted"))
@test result == ref

weave("documents/chunk_options.noweb", doctype="rst", plotlib=nothing)
result = readall(open("documents/chunk_options.rst"))
ref = readall(open("documents/chunk_options_ref.rst"))
@test result == ref

tangle("documents/chunk_options.noweb")
result = readall(open("documents/chunk_options.jl"))
ref = readall(open("documents/chunk_options_ref.jl"))
@test result == ref