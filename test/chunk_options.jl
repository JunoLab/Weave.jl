using Weave
using Base.Test

cleanup = true

weave("documents/chunk_options.noweb", plotlib=nothing)
result =  readstring(open("documents/chunk_options.md"))
ref =  readstring(open("documents/chunk_options_ref.md"))
@test result == ref
cleanup && rm("documents/chunk_options.md")
