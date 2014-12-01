# JuliaReport

[![Build Status](https://travis-ci.org/mpastell/JuliaReport.jl.svg?branch=master)](https://travis-ci.org/mpastell/JuliaReport.jl)

JuliaReport is a scientific report generator/literate programming tool
for Julia. It is based on [Pweave](http://mpastell.com/pweave) and
resembles Knitr and Sweave. Actually JuliaReport relies on Pweave for
document parsing and formatting.

You'll need latest Pweave from Github: <https://github.com/mpastell/Pweave.>

**Current features**

* Noweb syntax for documents.
* Execute code as terminal or "script" chunks.
* Capture PyPlot figures.
* All Pweave output formats supported. Including, Latex, Markdown, Sphinx etc.

**Not implemented**

* Script reader
* Inline code
* Caching

## Chunk options

You can use the same chunk options as for Pweave, but the format is different.
The syntax needs to be valid for creating a dictionary in Julia
without the `{}`. e.g:

    <<"term"=>true, "fig"=>false>>=


## Usage

Run from julia:

    using JuliaReport
    weave(Pkg.dir("JuliaReport","examples","julia_sample.mdw")
