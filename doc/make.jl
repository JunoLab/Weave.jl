using Documenter, Weave
start_dir = pwd()


makedocs( modules = Weave, sitename="Weave.jl",
    pages = ["index.md", "getting_started.md", "usage.md",
    "publish.md", "chunk_options.md", "notebooks.md",
    "function_index.md"]
)

cd(@__DIR__)
include("make_examples.jl")
cd(start_dir)

deploydocs(
    repo = "github.com/mpastell/Weave.jl.git",
    target = "build"
)
