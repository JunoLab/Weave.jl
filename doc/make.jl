using Documenter, Weave

makedocs(
    modules = [Weave],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "Weave.jl",
    pages = [
        "index.md",
        "getting_started.md",
        "usage.md",
        "publish.md",
        "chunk_options.md",
        "notebooks.md",
        "function_index.md",
    ],
)

include("make_examples.jl")

deploydocs(
    repo = "github.com/mpastell/Weave.jl.git",
    target = "build",
    push_preview = true,
)
