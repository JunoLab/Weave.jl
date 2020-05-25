using Documenter, Weave

CI_FLG = get(ENV, "CI", nothing) == "true"

makedocs(
    modules = [Weave],
    format = Documenter.HTML(
        prettyurls = CI_FLG,
        canonical = "http://weavejl.mpastell.com/stable/",
    ),
    sitename = "Weave.jl",
    pages = [
        "index.md",
        "getting_started.md",
        "usage.md",
        "publish.md",
        "chunk_options.md",
        "header.md",
        "notebooks.md",
        "function_index.md",
    ],
)

CI_FLG && include("make_examples.jl")

deploydocs(
    repo = "github.com/JunoLab/Weave.jl.git",
    push_preview = true,
)
