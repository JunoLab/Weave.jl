# Using Weave

You can write your documentation and code in input document using Markdown, Noweb or script
syntax and use [`weave`](@ref) function to execute to document to capture results and figures.

## `weave`

Weave document with markup and julia code using `Plots.jl` for plots,
`out_path = :pwd` makes the results appear in the current working directory.

> A prepared example: [`Weave.SAMPLE_JL_DOC`](../examples/FIR_design.jmd)

```julia
# First add depencies for the example
using Pkg; Pkg.add.(["Plots", "DSP"])
using Weave
weave(Weave.SAMPLE_JL_DOC; out_path=:pwd)
```

```@docs
weave
```

## `tangle`

Tangling extracts the code from document:

```@docs
tangle
```

## Supported Output Formats

Weave automatically detects the output format based on the file extension.
The auto output format detection is handled by `detect_doctype(path::AbstractString)`:

```julia
function detect_doctype(path::AbstractString)
    _, ext = lowercase.(splitext(path))

    match(r"^\.(jl|.?md|ipynb)", ext) !== nothing && return "md2html"
    ext == ".rst" && return "rst"
    ext == ".tex" && return "texminted"
    ext == ".txt"  && return "asciidoc"

    return "pandoc"
end
```

You can also manually specify it using the `doctype` keyword option.
You can get a list of supported output formats:

```@docs
list_out_formats
```

```@example
using Weave # hide
list_out_formats()
```

## [Document Syntax](@id document-syntax)

Weave uses markdown, Noweb or script syntax for defining the code chunks and
documentation chunks. You can also weave Jupyter notebooks. The format is detected based on the file extension, but you can also set it manually using the `informat` parameter.

The rules for autodetection are:

```julia
ext == ".jl" && return "script"
ext == ".jmd" && return "markdown"
ext == ".ipynb" && return "notebook"
return "noweb"
```

## Documentation Chunks

In markdown and Noweb input formats documentation chunks are the parts that aren't inside code delimiters. Documentation chunks can be written with several different markup languages.

## Code Chunks

### Markdown Format

Markdown code chunks are defined using fenced code blocks with options following on the same line. e.g. to hide code from output you can use:

```
 ```julia; echo=false
```

[Sample document]( https://github.com/mpastell/Weave.jl/blob/master/examples/FIR_design.jmd)

## [Inline Code](@id inline-code)

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


### Noweb Format

Code chunks start with a line marked with `<<>>=` or `<<options>>=` and end with line marked with `@`. The code between the start and end markers is executed and the output is captured to the output document. See [chunk options](../chunk_options/).


### Script Format

Weave also support script input format with a markup in comments.
These scripts can be executed normally using Julia or published with Weave.

Lines starting with `#'`, `#%%` or `# %%` are treated as document.

All non-document lines are treated as code.
You can set chunk options using lines starting with `#+` just before code e.g:
```julia
#+ term=true
hoge # some code comes here
```

The format is identical to [Pweave](http://mpastell.com/pweave/pypublish.html) and the concept is similar to publishing documents with MATLAB or using Knitr's [spin](http://yihui.name/knitr/demo/stitch/).
Weave will remove the first empty space from each line of documentation.

[See sample document:](https://github.com/mpastell/Weave.jl/blob/master/examples/FIR_design.jl)


## Configuration via YAML Header

When `weave`ing markdown files, you can use YAML header to provide additional metadata and configuration options.
See [Header Configuration](@ref) section for more details.


## Passing Runtime Arguments to Documents

You can pass arguments as `Dict` to the weaved document using the `args` argument
to `weave`. The arguments will be available as `WEAVE_ARGS` variable in the document.

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


## `include_weave`

You can call `include_weave` on a Weave document and run all code chunks within in the current session.

```@docs
include_weave
```
