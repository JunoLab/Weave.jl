using Weave
using Test

cleanup = true

VER = "$(VERSION.major).$(VERSION.minor)"

Weave.push_preexecute_hook(identity)
weave("documents/chunk_options.noweb")
Weave.pop_preexecute_hook(identity)
result =  read("documents/chunk_options.md", String)
ref =  read("documents/chunk_options_ref.md", String)
@test result == ref
cleanup && rm("documents/chunk_options.md")

tangle("documents/chunk_options.noweb", out_path = "documents/tangle")
result =  read("documents/tangle/chunk_options.jl", String)
ref =  read("documents/tangle/chunk_options.jl.ref", String)
@test ref == result
cleanup && rm("documents/tangle/chunk_options.jl")
