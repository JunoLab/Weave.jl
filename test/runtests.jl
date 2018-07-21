using Weave
using Test

@info("Test: Chunk options")
include("chunk_options.jl")

@info("Testing error handling")
include("errors_test.jl")

@info("Test: Converting")
include("convert_test.jl")

@info("Testing formatters")
include("formatter_test.jl")
include("markdown_test.jl")

@info("Testing figure formatters")
include("figureformatter_test.jl")

@info("Testing rich output")
include("rich_output.jl")


@info("Test: Caching")
include("cache_test.jl")

@info("Test: Chunk options with Gadfly")
include("chunk_opts_gadfly.jl")

#info("Test: Weaving with Gadfly")
#include("gadfly_formats.jl")

#info("Test: Weaving with PyPlot")
#include("pyplot_formats.jl")

@info("Test: Weaving with Plots.jl")
include("plotsjl_test.jl")
include("publish_test.jl")
