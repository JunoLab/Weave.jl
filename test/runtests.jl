using Weave
using Base.Test

include("chunk_options.jl")


weave("documents/gadfly_markdown_test.jmd", doctype="github",plotlib="gadfly", informat="markdown")
result = readall(open("documents/gadfly_markdown_test.md"))
ref = readall(open("documents/gadfly_markdown_test_ref.md"))
@test result == ref

include("gadfly_formats.jl")


#These segfault on Travis, but run without problems on my Fedora 21
# You should run both files when testing

#include("winston_formats.jl")
#include("pyplot_formats.jl") cause segfaults, but OK if run by itself
