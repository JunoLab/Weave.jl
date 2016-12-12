
<a id='Working-with-Jupyter-notebooks-1'></a>

# Working with Jupyter notebooks


<a id='Weaving-1'></a>

## Weaving


Weave supports using Jupyter notebooks as input format, this means you can weave notebooks to any supported formats. You can't use chunk options with notebooks.


```julia
weave("notebook.ipynb")
```


In order to output notebooks from other formats you need to convert the document to a notebook and run the code using IJulia.


<a id='Converting-between-formats-1'></a>

## Converting between formats


You can convert between all supported input formats using the `convert_doc` function.


To convert from script to notebook:


```julia
convert_doc("examples/FIR_design.jl", "FIR_design.ipynb")
```


and from notebooks to markdown use:


```julia
convert_doc("FIR_design.ipynb", "FIR_design.jmd")
```

<a id='Weave.convert_doc-Tuple{String,String}' href='#Weave.convert_doc-Tuple{String,String}'>#</a>
**`Weave.convert_doc`** &mdash; *Method*.



`convert_doc(infile::AbstractString, outfile::AbstractString; format = nothing)`

Convert Weave documents between different formats

  * `infile` = Name of the input document
  * `outfile` = Name of the output document
  * `format` = Output format (optional). Detected from outfile extension, but can be set to `"script"`, `"markdown"`, `"notebook"` or `"noweb"`.

