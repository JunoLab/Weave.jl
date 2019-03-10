
# Weave.jl - Scientific Reports Using Julia

This is the documentation of [Weave.jl](http://github.com/mpastell/weave.jl). Weave is a scientific report generator/literate programming tool
for Julia. It resembles [Pweave](http://mpastell.com/pweave), Knitr, rmarkdown
and Sweave.


**Current features**

* Markdown, script of Noweb syntax for input documents
* Publish markdown directly to html and pdf using Julia or Pandoc markdown
* Execute code as terminal or "script" chunks
* Capture Plots.jl or  Gadfly.jl figures
* Supports LaTex, Pandoc, Github markdown, MultiMarkdown, Asciidoc and reStructuredText output
* Simple caching of results
* Convert to and from IJulia notebooks

![Weave code and output](http://mpastell.com/images/weave_demo.png)

## Contents

```@contents
Pages = ["getting_started.md", "usage.md",
"publish.md", "chunk_options.md", "notebooks.md",
"function_index.md"]
```
