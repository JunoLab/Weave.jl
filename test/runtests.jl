using Weave
using Base.Test

include("chunk_options.jl")
#include("pyplot_formats.jl") cause segfaults, but OK if run by itself

weave("documents/gadfly_markdown_test.jmd", doctype="github",plotlib="gadfly", informat="markdown")
result = readall(open("documents/gadfly_markdown_test.md"))
ref = readall(open("documents/gadfly_markdown_test_ref.md"))
@test result == ref

#Test winston only for 0.3
if VERSION.minor == 3
    include("winston_formats.jl")
end

include("gadfly_formats.jl")
