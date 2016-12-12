
<a id='Intro-1'></a>

# Intro


This is the documentation of [Weave.jl](http://github.com/mpastell/weave.jl). Weave is a scientific report generator/literate programming tool for Julia. It resembles [Pweave](http://mpastell.com/pweave), Knitr, rmarkdown and Sweave.


**Current features**


  * Noweb, markdown or script syntax for input documents.
  * Execute code as terminal or "script" chunks.
  * Capture Plots, Gadfly, PyPlot and Winston figures.
  * Supports LaTex, Pandoc, Github markdown, MultiMarkdown, Asciidoc and reStructuredText output
  * Publish markdown directly to html and pdf using Pandoc.
  * Simple caching of results
  * Convert to and from IJulia notebooks


![Weave code and output](http://mpastell.com/images/weave_demo.png)


<a id='Contents-1'></a>

## Contents

- [Getting started](getting_started.md#Getting-started-1)
- [Using Weave](usage.md#Using-Weave-1)
    - [Weave](usage.md#Weave-1)
    - [Weave from shell](usage.md#Weave-from-shell-1)
    - [Tangle](usage.md#Tangle-1)
    - [Supported formats](usage.md#Supported-formats-1)
    - [Document syntax](usage.md#Document-syntax-1)
    - [Noweb](usage.md#Noweb-1)
    - [Markdown](usage.md#Markdown-1)
- [Publishing scripts](publish.md#Publishing-scripts-1)
    - [Other mark ups with scripts](publish.md#Other-mark-ups-with-scripts-1)
- [Chunk options](chunk_options.md#Chunk-options-1)
    - [Options for code](chunk_options.md#Options-for-code-1)
    - [Options for figures](chunk_options.md#Options-for-figures-1)
    - [Set default chunk options](chunk_options.md#Set-default-chunk-options-1)
- [Working with Jupyter notebooks](notebooks.md#Working-with-Jupyter-notebooks-1)
    - [Weaving](notebooks.md#Weaving-1)
    - [Converting between formats](notebooks.md#Converting-between-formats-1)
- [Function index](function_index.md#Function-index-1)

