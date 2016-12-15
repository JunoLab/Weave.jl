# Using Weave

You can write your documentation and code in input document using Noweb, Markdown or script
syntax and use `weave` function to execute to document to capture results and figures.

## Weave

Weave document with markup and julia code using Gadfly for plots,
`out_path = :pwd` makes the results appear in the current working directory.

```julia
using Weave
weave(Pkg.dir("Weave","examples","gadfly_sample.mdw"), out_path = :pwd)
```

Using PyPlot:

```julia
weave(Pkg.dir("Weave","examples","julia_sample.mdw"), plotlib="PyPlot", out_path = :pwd)
```

```@docs
weave(source)
```

## Weave from shell

You can also use the `weave.jl` script under bin directory to weave documents
from the shell:

```
$ ./weave.jl
usage: weave.jl [--doctype DOCTYPE] [--plotlib PLOTLIB]
                [--informat INFORMAT] [--out_path OUT_PATH]
                [--fig_path FIG_PATH] [--fig_ext FIG_EXT] source...
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

```@repl
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
