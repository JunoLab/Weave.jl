# Using Weave

You can write your documentation and code in input document using Noweb or Markdown syntax and use `weave` function to execute to document to capture results and figures.

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

    {docs}
      weave(source)

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

    {docs}
      tangle(source)


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

```
julia> list_out_formats()
pandoc: Pandoc markdown
rst: reStructuredText and Sphinx
texminted: Latex using minted for highlighting
github: Github markdown
md2html: Markdown to HTML (requires Pandoc)
md2pdf: Markdown to pdf (requires Pandoc and xelatex)
asciidoc: AsciiDoc
tex: Latex with custom code environments
```

    {docs}
      list_out_formats()

## Document syntax

Weave uses noweb, markdown or script syntax for defining the code chunks and
documentation chunks. The format is detected based on the file extension, but
you can also set it manually using the `informat` parameter.

The rules for autodetection are:

```
ext == ".jl" && return "script"
ext == ".jmd" && return "markdown"
return "noweb"
```



## Noweb

### Code chunks
start with a line marked with `<<>>=` or `<<options>>=` and end with line marked with `@`. The code between the start and end markers is executed and the output is captured to the output document. See for options below.

### Documentation chunks

Are the rest of the document (between `@` and `<<>>=` lines and the first chunk be default) and can be written with several different markup languages.

[Sample document]( https://github.com/mpastell/Weave.jl/blob/master/examples/julia_sample.mdw)

## Markdown

Markdown code chunks are defined using fenced code blocks. [See sample document:](https://github.com/mpastell/Weave.jl/blob/master/examples/gadfly_sample.jmd)
