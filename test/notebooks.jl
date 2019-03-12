file = joinpath(@__DIR__, "documents", "jupyter_test.jmd")
using IJulia

Weave.notebook(file)
@test "jupyter_test.ipynb" ∈ readdir(@__DIR__) # test if the result was weaved
