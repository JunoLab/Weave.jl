using Weave
using Base.Test

# Running Changin plotlib in tests segfault, unless they are run
# using separate processes.
#run(`julia --code-coverage=user -e 'include("winston_formats.jl")'`)
#run(`julia --code-coverage=user -e 'include("pyplot_formats.jl")'`)

info("Test: Chunk options")
include("chunk_options.jl")

# Cache is currently not implemented for new output format
#info("Test: Caching")
#include("cache_test.jl")

# Winston support not updated for 0.4
# info("Test: Weaving with Winston")
# include("winston_formats.jl")


info("Test: Weaving with Gadfly")
include("gadfly_formats.jl")

info("Test: Weaving with PyPlot")
include("pyplot_formats.jl")
