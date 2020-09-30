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


### Documentation Chunks

In markdown and Noweb input formats documentation chunks are the parts that aren't inside code delimiters. Documentation chunks can be written with several different markup languages.


### [Code Chunks](@id code-chunks)

Code chunks are written in different ways in different formats.

#### Markdown Format

Weave code chunks are defined using fenced code blocks, same as with [common markdown](https://spec.commonmark.org/0.29/#fenced-code-blocks):
```markdown
 ```julia
 code
 ...
 ```
```

Weave code chunks can optionally be followed by [chunk options](@ref) on the same line.
E.g. the chunk below will hide code itself from generated output:
```markdown
 ```julia, echo = false
 code
 ...
 ```
```

#### Noweb Format

Code chunks start with a line marked with `<<>>=` or `<<options>>=` and end with line marked with `@`.
The code between the start and end markers is executed and the output is captured to the output document.

### [Inline Code](@id inline-code)

You can also add inline code to your documents using
```
`j juliacode`
```
or
```
! juliacode
```
syntax.

The former syntax allows you to insert code _anywhere_ in a line
while the `!` syntax treats the whole line as code,
and the code will be replaced with captured output in the weaved document.

If the code produces figures, the filename or base64 encoded string will be added to output,
e.g. to include a Plots figure in markdown you can use:
```
![A plot](`j plot(1:10)`)
```
or to produce any HTML output:
```
! display("text/html", "Header from julia");
```

### Script Format

Weave also supports script input format with a markup in comments.
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

!!! tip
    - Here are sample documents:
      + [markdown format](https://github.com/JunoLab/Weave.jl/blob/master/examples/FIR_design.jmd)
      + [script format](https://github.com/JunoLab/Weave.jl/blob/master/examples/FIR_design.jl)
    - [Details about chunk options](@ref chunk-options)


## Configuration via YAML Header

When `weave`ing markdown files, you can use YAML header to provide additional metadata and configuration options.
See [Header Configuration](@ref) section for more details.


## Passing Runtime Arguments to Documents

You can pass arbitrary object to the weaved document using [`weave`](@ref)'s optional argument `args`.
It will be available as `WEAVE_ARGS` variable in the `weave`d document.

This makes it possible to create the same report easily for e.g. different date ranges of input data from a database or from files with similar format giving the filename as input.

E.g. if you call `weave("weavefile.jmd", args = (datalocation = "somedata.h5",))`, and then you can retrieve `datalocation` in `weavefile.jmd` as follows: `WEAVE_ARGS.datalocation`


## `include_weave`

You can call `include_weave` on a Weave document and run all code chunks within in the current session.

```@docs
include_weave
```
