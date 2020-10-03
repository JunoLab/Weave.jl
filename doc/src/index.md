# Weave.jl - Scientific Reports Using Julia

This is the documentation of [Weave.jl](http://github.com/mpastell/weave.jl).
Weave is a scientific report generator/literate programming tool for Julia.
It resembles
[Pweave](http://mpastell.com/pweave),
[knitr](https://yihui.org/knitr/),
[R Markdown](https://rmarkdown.rstudio.com/),
and [Sweave](https://stat.ethz.ch/R-manual/R-patched/library/utils/doc/Sweave.pdf).


**Current features**

- Publish markdown directly to HTML and PDF using Julia or [Pandoc](https://pandoc.org/MANUAL.html)
- Execute code as in terminal or in a unit of code chunk
- Capture [Plots.jl](https://github.com/JuliaPlots/Plots.jl) or [Gadfly.jl](https://github.com/GiovineItalia/Gadfly.jl) figures
- Supports various input format: Markdown, [Noweb](https://www.cs.tufts.edu/~nr/noweb/), [Jupyter Notebook](https://jupyter.org/), and ordinal Julia script
- Conversions between those input formats
- Supports various output document formats: HTML, PDF, GitHub markdown, Jupyter Notebook, MultiMarkdown, Asciidoc and reStructuredText
- Simple caching of results

![Weave in Juno demo](https://user-images.githubusercontent.com/40514306/76081328-32f41900-5fec-11ea-958a-375f77f642a2.png)


## Index

```@contents
Pages = [
    "index.md",
    "getting_started.md",
    "usage.md",
    "publish.md",
    "chunk_options.md",
    "header.md",
    "notebooks.md",
    "function_index.md",
]
```
