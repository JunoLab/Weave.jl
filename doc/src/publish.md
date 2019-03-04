# Publishing to html and pdf

You can also publish any supported input format using markdown for doc chunks to html and pdf documents. Producing pdf output requires that you have pdflatex installed and in your path.

You can use a YAML header in the beginning of the input document delimited with "---"
to set the document title, author and date e.g.

```
---
title : Weave example
author : Matti Pastell
date: 15th December 2016
---
```

Here is a a sample document and output:

[FIR_design_plots.jl](../examples/FIR_design_plots.jl), [FIR_design_plots.html](../examples/FIR_design_plots.html) , [FIR_design_plots.pdf](../examples/FIR_design_plots.pdf).

```julia
weave("FIR_design_plots.jl")
weave("FIR_design_plots.jl", docformat = "md2pdf")
```

**Note:** docformats `md2pdf` and `md2html` use Julia markdown and `pandoc2pdf` and `pandoc2html`
use Pandoc.

## Templates

You can use a custom template with `md2pdf` and `md2html` formats with `template`
argument (e.g) `weave("FIR_design_plots.jl", template = "custom.tpl"`). You can use
the existing templates as starting point.

For HTML: [julia_html.tpl](https://github.com/mpastell/Weave.jl/blob/master/templates/julia_html.tpl) and LaTex: [julia_tex.tpl](https://github.com/mpastell/Weave.jl/blob/master/templates/julia_tex.tpl)

Templates are rendered using [Mustache.jl](https://github.com/jverzani/Mustache.jl).

## Supported Markdown syntax

The markdown variant used by Weave is [Julia markdown](http://docs.julialang.org/en/latest/manual/documentation.html#Markdown-syntax-1). In addition Weave supports few additional Markdown features:

**Comments**

You can add comments using html syntax: `<!-- -->`

**Multiline equations**

You can add multiline equations using:

```
$$
x^2 = x*x
$$
```
