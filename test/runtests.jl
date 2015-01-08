using Weave
using Base.Test

# Running Changin plotlib in tests segfault, unless they are run
# using separate processes.
#run(`julia --code-coverage=user -e 'include("winston_formats.jl")'`)
#run(`julia --code-coverage=user -e 'include("pyplot_formats.jl")'`)

info("Test: Chunk options")
include("chunk_options.jl")

info("Test: Caching")
include("cache_test.jl")

info("Test: Weaving with Winston")
include("winston_formats.jl")

info("Test: Weaving with Gadfly")
include("gadfly_formats.jl")

weave("documents/gadfly_markdown_test.jmd", doctype="github",plotlib="gadfly", informat="markdown")
result = readall(open("documents/gadfly_markdown_test.md"))
ref = readall(open("documents/gadfly_markdown_test_ref.md"))
@test result == ref
