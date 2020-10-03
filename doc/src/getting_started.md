
# Getting started

The best way to get started using Weave.jl is to look at the example input and output documents.
Examples for different formats are included in the package's [`examples`](https://github.com/JunoLab/Weave.jl/tree/master/examples) directory.

First have a look at source document using markdown code chunks and [Plots.jl](https://github.com/JuliaPlots/Plots.jl) for figures:

All the different format documents below are generated from a single Weave document [`FIR_design.jmd`](../examples/FIR_design.jmd):
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

filename = normpath(Weave.EXAMPLE_FOLDER, "FIR_design.jmd")

# Julia markdown to HTML
weave(filename; doctype = "md2html", out_path = :pwd)

# Julia markdown to PDF
weave(filename; doctype = "md2pdf", out_path = :pwd)

# Julia markdown to Pandoc markdown
weave(filename; doctype = "pandoc", out_path = :pwd)
```

!!! tips
    `Weave.EXAMPLE_FOLDER` points to [the `examples` directory](https://github.com/JunoLab/Weave.jl/tree/master/examples).
