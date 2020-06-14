# Publishing to HTML and PDF

You can also publish any supported input format to HTML and PDF documents.

!!! note
    Producing PDF output requires that you have XeLaTex installed and in your path.

You can use a YAML header in the beginning of the input document delimited with `---`
to set the document title, author and date, e.g.:
```
---
title : Weave example
author : Matti Pastell
date: 15th December 2016
---
```

Here are sample input and outputs:
- input (Julia markdown format): [`FIR_design_plots.jl`](../examples/FIR_design_plots.jl) (its path is bound to `Weave.SAMPLE_JL_DOC`)
- HTML output: [`FIR_design_plots.html`](../examples/FIR_design_plots.html)
-  PDF output: [`FIR_design_plots.pdf`](../examples/FIR_design_plots.pdf)

They are generated as follows:
```julia
weave(Weave.SAMPLE_JL_DOC)) # default to md2html output format
weave(Weave.SAMPLE_JL_DOC; doctype = "md2pdf")
```

!!! tips
    `Weave.SAMPLE_JL_DOC` is the path of [FIR_design.jl](../examples/FIR_design.jl).

!!! note
    `"md2html"` and `"md2pdf"` assume Julia markdown format as an input,
    while `pandoc2pdf` and `pandoc2html` assume Noweb input format (i.e. Pandoc markdown).


## Templates

You can use a custom template with `md2html` and `md2pdf` formats with `template` keyword option,
e.g.: `weave("FIR_design_plots.jl", template = "custom.tpl"`.

As starting point, you can use the existing templates:

- HTML (`md2html`): [`md2html.tpl`](https://github.com/JunoLab/Weave.jl/blob/master/templates/md2html.tpl)
- LaTex (`md2pdf`): [`md2pdf.tpl`](https://github.com/JunoLab/Weave.jl/blob/master/templates/md2pdf.tpl)

Templates are rendered using [Mustache.jl](https://github.com/jverzani/Mustache.jl).


## Supported Markdown syntax

The markdown variant used by Weave is [Julia markdown](https://docs.julialang.org/en/v1/stdlib/Markdown/#).
In addition Weave supports few additional Markdown features:

### Comments

You can add comments using html syntax: `<!-- -->`

### Multiline equations

You can add multiline equations using:

```
$$
x^2 = x*x
$$
```
