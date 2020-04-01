
# Getting started

The best way to get started using Weave.jl is to look at the example input and
output documents. Examples for different formats are included in the packages
[`examples`](https://github.com/JunoLab/Weave.jl/tree/master/examples) directory.

First have a look at source document using markdown code chunks and
[Plots.jl](https://github.com/JuliaPlots/Plots.jl) for figures:
[FIR_design.jmd](../examples/FIR_design.jmd) and then see the
output in different formats:

- HTML: [`FIR_design.html`](../examples/FIR_design.html)
- PDF: [`FIR_design.pdf`](../examples/FIR_design.pdf)
- Pandoc markdown: [`FIR_design.txt`](../examples/FIR_design.txt)

!!! note
    Producing PDF output requires that you have XeLateX installed.

Add dependencies for the example if needed:

```julia
using Pkg; Pkg.add.(["Plots", "DSP"])
```

Weave the files to your working directory:

```julia
using Weave

# Julia markdown to HTML
weave(
  joinpath(dirname(pathof(Weave)), "../examples", "FIR_design.jmd");
  doctype = "md2html",
  out_path = :pwd
)

# Julia markdown to PDF
weave(
  joinpath(dirname(pathof(Weave)), "../examples", "FIR_design.jmd");
  doctype = "md2pdf",
  out_path = :pwd
)

# Julia markdown to Pandoc markdown
weave(
  joinpath(dirname(pathof(Weave)), "../examples", "FIR_design.jmd");
  doctype = "pandoc",
  out_path = :pwd
)
```
