# Using Weave

You can write your documentation and code in input document using Noweb, Markdown or script
syntax and use `weave` function to execute to document to capture results and figures.

## Weave

Weave document with markup and julia code using `Plots.jl` for plots,
`out_path = :pwd` makes the results appear in the current working directory.

```julia
#First add depencies for the example
using Pkg; Pkg.add.(["Plots", "DSP"])
using Weave
weave(joinpath(dirname(pathof(Weave)), "../examples", "FIR_design.jmd"), out_path=:pwd)
```

```@docs
weave(source)
```

## Tangle

Tangling extracts the code from document:

```@docs
tangle(source)
```

## Supported formats

Weave sets the output format based on the file extension, but you can also set
it using `doctype` option. The rules for detecting the format are:

```julia
ext == ".jl" && return "md2html"
contains(ext, ".md") && return "md2html"
contains(ext, ".rst") && return "rst"
contains(ext, ".tex") && return "texminted"
contains(ext, ".txt") && return "asciidoc"
return "pandoc"
```

You can get a list of supported output formats:

```@example
using Weave # hide
list_out_formats()
```

```@docs
list_out_formats()
```

## Document syntax

Weave uses noweb, markdown or script syntax for defining the code chunks and
documentation chunks. You can also weave Jupyter notebooks. The format is detected based on the file extension, but you can also set it manually using the `informat` parameter.

The rules for autodetection are:

```julia
ext == ".jl" && return "script"
ext == ".jmd" && return "markdown"
ext == ".ipynb" && return "notebook"
return "noweb"
```

## Noweb format

### Code chunks
start with a line marked with `<<>>=` or `<<options>>=` and end with line marked with `@`. The code between the start and end markers is executed and the output is captured to the output document. See [chunk options](../chunk_options/).

### Documentation chunks

Are the rest of the document (between `@` and `<<>>=` lines and the first chunk be default) and can be written with several different markup languages.

[Sample document]( https://github.com/mpastell/Weave.jl/blob/master/examples/julia_sample.mdw)

## Markdown format

Markdown code chunks are defined using fenced code blocks with options following on the same line. e.g. to hide code from output you can use:

` ```julia; echo=false`

[See sample document:](https://github.com/mpastell/Weave.jl/blob/master/examples/gadfly_md_sample.jmd)

## Script format

Weave also support script input format with a markup in comments.
These scripts can be executed normally using Julia or published with
Weave.  Documentation is in lines starting with
`#'`, `#%%` or `# %%`, and code is executed and results are included
in the weaved document.

All lines that are not documentation are treated as code. You can set chunk options
using lines starting with `#+` just before code e.g. `#+ term=true`.

The format is identical to [Pweave](http://mpastell.com/pweave/pypublish.html)
and the concept is similar to publishing documents with MATLAB or
using Knitr's [spin](http://yihui.name/knitr/demo/stitch/).
Weave will remove the first empty space from each line of documentation.


[See sample document:](https://github.com/mpastell/Weave.jl/blob/master/examples/FIR_design.jl)

## Inline code

You can also add inline code to your documents using

```
`j juliacode`
```

syntax. The code will be replaced with the output of running the code.
If the code produces figures the filename or base64 encoded string will be
added to output e.g. to include a Plots figure in markdown you can use:

```
![A plot](`j plot(1:10)`)
```

## Passing arguments to documents

You can pass arguments as dictionary to the weaved document using the `args` argument
to `weave`. The dictionary will be available as `WEAVE_ARGS` variable in the document.

This makes it possible to create the same report easily for e.g. different
date ranges of input data from a database or from files with similar format giving the
filename as input.

In order to pass a filename to a document you need call `weave` using:

```julia
weave("mydoc.jmd", args = Dict("filename" => "somedata.h5"))
```

and you can access the filename from document as follows:

```
 ```julia
 print(WEAVE_ARGS["filename"])
 ```
```

You can use the `out_path` argument to control the name of the
output document.

## Include Weave document in Julia

You can call `include_weave` on a Weave document to run the contents
of all code chunks in Julia.

```@docs
include_weave(doc, informat=:auto)
```
