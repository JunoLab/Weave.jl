
# Working with Jupyter notebooks

## Weaving

Weave supports using Jupyter notebooks as input format, this means you can weave notebooks to any supported formats. You can't use chunk options with notebooks.

```julia
weave("notebook.ipynb")
```

In order to output notebooks from other formats you need to convert the
document to a notebook and run the code using IJulia.

## Converting between formats

You can convert between all supported input formats using the `convert_doc`
function.

To convert from script to notebook:

```julia
convert_doc("examples/FIR_design.jl", "FIR_design.ipynb")
```

and from notebooks to markdown use:

```julia
convert_doc("FIR_design.ipynb", "FIR_design.jmd")
```

```@docs
convert_doc(infile::String, outfile::String)
```
