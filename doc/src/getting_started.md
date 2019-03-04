
# Getting started

The best way to get started using Weave.jl is to look at the example input and
output documents. Examples for different formats are included in the packages `examples` directory.

First have a look at source document using markdown code chunks and Plots.jl for
figures: [FIR_design.jmd](../examples/FIR_design.jmd) and then see the
output in different formats:

  - HTML: [FIR_design.html](../examples/FIR_design.html)
  - pdf: [FIR_design.pdf](../examples/FIR_design.pdf)
  - Pandoc markdown: [FIR_design.txt](../examples/FIR_design.txt)

*Producing pdf output requires that you have XeLateX installed.*

Add dependencies for the example if needed:

```julia
using Pkg; Pkg.add.(["Plots", "DSP"])
```

Weave the files to your working directory using:

```julia
using Weave
#HTML
weave(joinpath(dirname(pathof(Weave)), "../examples", "FIR_design.jmd"),
  out_path=:pwd,
  doctype = "md2html")
#pdf
weave(joinpath(dirname(pathof(Weave)), "../examples", "FIR_design.jmd"),
  out_path=:pwd,
  doctype = "md2pdf")
  #Markdown
weave(joinpath(dirname(pathof(Weave)), "../examples", "FIR_design.jmd"),
      doctype="pandoc"
      out_path=:pwd)
```
