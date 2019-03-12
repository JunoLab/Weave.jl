file = joinpath(@__DIR__, "documents", "include_test.jmd")

Weave.notebook(file, "temp_notebook.ipynb")
@test "temp_notebook.ipynb" ∈ readdir(@__DIR__)
