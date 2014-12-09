using Weave
using Base.Test
Pkg.add("Gadfly")
Pkg.add("Cairo")
Pkg.add("Winston")


include("chunk_options.jl")
#include("pyplot_formats.jl") cause segfaults, but OK if run by itself


#Test Gadfly and markdown reader, Gadfly only works with 0.3
if VERSION.minor == 3
    weave("documents/gadfly_markdown_test.jmd", doctype="github",plotlib="gadfly", informat="markdown")
    result = readall(open("documents/gadfly_markdown_test.md"))
    ref = readall(open("documents/gadfly_markdown_test_ref.md"))
    @test result == ref

    include("winston_formats.jl")
    include("gadfly_formats.jl")
end
