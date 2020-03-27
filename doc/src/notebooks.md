
# Working with Jupyter notebooks

## Weaving from Jupyter notebooks

Weave supports using [Jupyter Notebook](https://jupyter.org/)s as input format.
This means you can [`weave`](@ref) notebooks to any supported formats;
by default, it will be weaved to HTML.

```julia
weave("notebook.ipynb") # will be weaved to HTML
```

!!! warning
    You can't use chunk options with notebooks.

## Output to Jupyter notebooks

As of Weave 0.5.1. there is new [`notebook`](@ref) method to convert Weave documents to Jupyter notebooks using
[nbconvert](http://nbconvert.readthedocs.io/en/latest/execute_api.html).

```@docs
notebook
```

You can specify `jupyter` used to execute the notebook with the `jupyter_path` keyword argument
(this defaults to the `"jupyter"`, i.e. whatever you have linked to that location).

Instead, you might want to use the [`convert_doc`](@ref) method below and run the code in Jupyter.

## Converting between formats

You can convert between all supported input formats using the [`convert_doc`](@ref) function.

To convert from script to notebook:

```julia
convert_doc("examples/FIR_design.jl", "FIR_design.ipynb")
```

and from notebook to Markdown use:

```julia
convert_doc("FIR_design.ipynb", "FIR_design.jmd")
```

```@docs
convert_doc(infile::AbstractString, outfile::AbstractString)
```
