import PyPlot
using Weave
using Base.Test

info("Test: Chunk options")
include("chunk_options.jl")

info("Test: Converting")
include("convert_test.jl")

info("Testing formatters")
include("formatter_test.jl")

info("Testing rich output")
include("rich_output.jl")

