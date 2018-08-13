using Documenter, Weave

makedocs(modules = Weave)
include("make_examples.jl")
run(`mkdocs build`)
