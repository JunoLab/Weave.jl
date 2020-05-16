using Documenter, Weave

makedocs(
    modules = [Weave],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "http://weavejl.mpastell.com/stable/",
    ),
    sitename = "Weave.jl",
    pages = [
        "index.md",
        "getting_started.md",
        "usage.md",
        "publish.md",
        "header.md",
        "chunk_options.md",
        "notebooks.md",
        "function_index.md",
    ],
)

include("make_examples.jl")

deploydocs(
    repo = "github.com/JunoLab/Weave.jl.git",
    push_preview = true,
)
