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

info("Testing rich output")
include("rich_output.jl")

if VERSION < v"0.5-dev"
  info("Test: Chunk options with Gadfly")
  include("chunk_opts_gadfly.jl")

  #Fails on travis, works locally.
  info("Test: Weaving with Winston")
  include("winston_formats.jl")

  info("Test: Weaving with Gadfly")
  include("gadfly_formats.jl")

  info("Test: Weaving with PyPlot")
  include("pyplot_formats.jl")

  info("Test: Weaving with Plots.jl")
  include("plotsjl_test.jl")
end
