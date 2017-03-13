using Weave
using Base.Test

cleanup = true

VER = "$(VERSION.major).$(VERSION.minor)"

weave("documents/chunk_options.noweb", plotlib=nothing)
result =  readstring("documents/chunk_options.md")
ref =  readstring("documents/$VER/chunk_options_ref.md")
@test result == ref
cleanup && rm("documents/chunk_options.md")


tangle("documents/chunk_options.noweb", out_path = "documents/tangle")
result =  readstring("documents/tangle/chunk_options.jl")
ref =  readstring("documents/tangle/chunk_options.jl.ref")
@test ref == result
cleanup && rm("documents/tangle/chunk_options.jl")
