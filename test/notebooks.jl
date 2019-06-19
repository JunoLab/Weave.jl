file = joinpath(@__DIR__, "documents", "jupyter_test.jmd")
using IJulia, Conda

Conda.add("nbconvert") # should be the same as IJulia.JUPYTER, i.e. the miniconda Python

Weave.notebook(file, jupyter_path = IJulia.JUPYTER)
@test "jupyter_test.ipynb" ∈ readdir(@__DIR__) # test if the result was weaved
