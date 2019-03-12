file = joinpath(@__DIR__, "documents", "jupyter_test.jmd")
using IJulia, Conda

Conda.add("jupyter")
Conda.add("nbconvert")

Weave.notebook(file, jupyter_path = joinpath(Conda.ROOTENV, "bin", "jupyter"))
@test "temp_notebook.ipynb" ∈ readdir(@__DIR__) # test if the result was weaved
