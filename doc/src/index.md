
# Intro

This is the documentation of [Weave.jl](http://github.com/mpastell/weave.jl). Weave is a scientific report generator/literate programming tool
for Julia. It resembles [Pweave](http://mpastell.com/pweave) and, Knitr
and Sweave.


**Current features**

* Noweb or markdown syntax for input documents.
* Execute code as terminal or "script" chunks.
* Capture Gadfly, PyPlot or Winston figures.
* Supports LaTex, Pandoc and Github markdown, AsciiDoc and reStructuredText output

## Contents

    {contents}

## Usage

You can write your documentation and code in input document using Noweb or Markdown syntax and use `weave` function to execute to document to capture results and figures.

### Weave

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

### Weave from shell

You can also use the `weave.jl` script under bin directory to weave documents
from the shell:

```
$ ./weave.jl
usage: weave.jl [--doctype DOCTYPE] [--plotlib PLOTLIB]
                [--informat INFORMAT] [--out_path OUT_PATH]
                [--fig_path FIG_PATH] [--fig_ext FIG_EXT] source...
```

### Tangle

Tangling extracts the code from document:

    {docs}
      tangle(source)



## Supported formats

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

Weave uses noweb or markdown syntax for defining the code chunks and documentation chunks.

### Noweb

#### Code chunks
start with a line marked with `<<>>=` or `<<options>>=` and end with line marked with `@`. The code between the start and end markers is executed and the output is captured to the output document. See for options below.

#### Documentation chunks

Are the rest of the document (between `@` and `<<>>=` lines and the first chunk be default) and can be written with several different markup languages.

[Sample document]( https://github.com/mpastell/Weave.jl/blob/master/examples/julia_sample.mdw)

### Markdown

Markdown code chunks are defined using fenced code blocks. [See sample document:](https://github.com/mpastell/Weave.jl/blob/master/examples/gadfly_sample.jmd)

## Chunk options

I've mostly followed [Knitr](http://yihui.name/knitr/options)'s naming for chunk options, but not all options are implemented.

Options are separated using ";" and need to be valid Julia expressions. Example: A code chunk that saves and displays a 12 cm wide image and hides the source code:

```julia
<<fig_width=5; echo=false >>=
using Gadfly
x = linspace(0, 2π, 200)
plot(x=x, y = sin(x), Geom.line)
@
```

Weave currently supports the following chunk options with the following defaults:

### Options for code

* `echo = true`. Echo the code in the output document. If `false` the source code will be hidden.
* `results = "markup"`. The output format of the printed results. "markup" for literal block, "hidden" for hidden results or anything else for raw output (I tend to use ‘tex’ for Latex and ‘rst’ for rest. Raw output is useful if you wan’t to e.g. create tables from code chunks.
* `eval = true`. Evaluate the code chunk. If false the chunk won’t be executed.
* `term=false`. If true the output emulates a REPL session. Otherwise only stdout and figures will be included in output.
* `label`. Chunk label, will be used for figure labels in Latex as fig:label
* `wrap = true`. Wrap long lines from output.
* `line_width = 75`. Line width for wrapped lines.
* `cache = false`. Cache results, depends on `cache` parameter on `weave` function.
* `hold = false`. Hold all results until the end of the chunk.

### Options for figures

* `fig_width`. Figure width defined in markup, default depends on the output format.
* `out_width`. Width of saved figure.
* `out_height`. Height of saved figure.
* `dpi`=96. Resolution of saved figures.
* `fig_cap`. Figure caption.
* `label`. Chunk label, will be used for figure labels in Latex as fig:label
* `fig_ext`. File extension (format) of saved figures.
* `fig_pos="htpb"`. Figure position in Latex.  
* `fig_env="figure"`. Figure environment in Latex.


## Set default chunk options

You can set or alter the default chunk options for a document either before
running weave or inside the weaved document. You can e.g. use a hidden chunk
in the beginning of the source document to set the options:

```
<<echo = false>>=
import Weave
Weave.set_chunk_defaults(Dict{Symbol, Any}(
      :out_width => "\\0.5linewidth",
      :results => "tex"
      ))
@
```


    {docs}
      set_chunk_defaults(opts)
      get_chunk_defaults()
      restore_chunk_defaults()

## Function index

    {index}
