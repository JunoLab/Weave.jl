
# Working with Jupyter notebooks

## Weaving from Jupyter notebooks

Weave supports using Jupyter notebooks as input format, this means you
can weave notebooks to any supported formats. You can't use chunk options with notebooks.

```julia
weave("notebook.ipynb")
```

## Output to Jupyter notebooks

As of Weave 0.5.1. there is new `notebook` method to convert Weave documents
to Jupyter notebooks using [nbconvert](http://nbconvert.readthedocs.io/en/latest/execute_api.html). The code **is not executed by Weave**
and the output doesn't always work properly,
see [#116](https://github.com/mpastell/Weave.jl/issues/116).

```@docs
notebook(source::String, out_path=:pwd)
```

You might want to use the `convert_doc` method below instead and run the code in Jupyter.

You can select the `jupyter` used to execute the notebook with the `jupyter_path` argument (this defaults to the string "jupyter," i.e., whatever you have linked to that location.)

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
