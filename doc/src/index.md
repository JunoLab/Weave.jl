
# Intro

This is the documentation of [Weave.jl](http://github.com/mpastell/weave.jl). Weave is a scientific report generator/literate programming tool
for Julia. It resembles [Pweave](http://mpastell.com/pweave), Knitr, rmarkdown
and Sweave.


**Current features**

* Noweb, markdown or script syntax for input documents.
* Execute code as terminal or "script" chunks.
* Capture Plots, Gadfly, PyPlot and Winston figures.
* Supports LaTex, Pandoc, Github markdown, MultiMarkdown, Asciidoc and reStructuredText output
* Publish markdown directly to html and pdf using Pandoc.
* Simple caching of results
* Convert to and from IJulia notebooks

![Weave code and output](http://mpastell.com/images/weave_demo.png)

## Contents

```@contents
Pages = ["getting_started.md", "usage.md",
"publish.md", "chunk_options.md", "notebooks.md",
"function_index.md"]
```
