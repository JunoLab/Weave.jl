# Using Weave

You can write your documentation and code in input document using Markdown, Noweb or script
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

## Supported output formats

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

Weave uses markdown, Noweb or script syntax for defining the code chunks and
documentation chunks. You can also weave Jupyter notebooks. The format is detected based on the file extension, but you can also set it manually using the `informat` parameter.

The rules for autodetection are:

```julia
ext == ".jl" && return "script"
ext == ".jmd" && return "markdown"
ext == ".ipynb" && return "notebook"
return "noweb"
```

## Documentation chunks

In Markdown and Noweb input formats documentation chunks are the parts that aren't inside code delimiters. Documentation chunks can be written with several different markup languages.

## Code chunks

### Markdown format

Markdown code chunks are defined using fenced code blocks with options following on the same line. e.g. to hide code from output you can use:

```
 ```julia; echo=false`
```

[Sample document]( https://github.com/mpastell/Weave.jl/blob/master/examples/FIR_design.jmd)

## Inline code

You can also add inline code to your documents using

```
`j juliacode`
```

or

```
! juliacode
```

syntax. Using the `j code` syntax you can insert code anywhere in a line and with  
the `!` syntax the whole line after `!` will be executed. The code will be replaced
with captured output in the weaved document.

If the code produces figures the filename or base64 encoded string will be
added to output e.g. to include a Plots figure in markdown you can use:

```
![A plot](`j plot(1:10)`)
```

or to produce any html output:

```
! display("text/html", "Header from julia");
```


### Noweb format

Code chunks start with a line marked with `<<>>=` or `<<options>>=` and end with line marked with `@`. The code between the start and end markers is executed and the output is captured to the output document. See [chunk options](../chunk_options/).


### Script format

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

## Setting document options in header

You can use a YAML header in the beginning of the input document delimited with "---" to set the document title, author and date e.g. and default document options. Each of Weave command line arguments and chunk options can be set in header using `options` field. Below is an example that sets document `out_path` and `doctype` using the header.


```yaml
---
title : Weave example
author : Matti Pastell
date: 15th December 2016
options:
  out_path : reports/example.md
  doctype :  github
---
```

You can also set format specific options. Here is how to set different `out_path` for `md2html` and `md2pdf` and set `fig_ext` for both:

```
---
options:
    md2html:
        out_path : html
    md2pdf:
        out_path : pdf
    fig_ext : .png
---
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
