# JuliaReport

[![Build Status](https://travis-ci.org/mpastell/JuliaReport.jl.svg?branch=master)](https://travis-ci.org/mpastell/JuliaReport.jl)

JuliaReport is a scientific report generator/literate programming tool
for Julia. It resembles [Pweave](http://mpastell.com/pweave) and, Knitr
and Sweave.


**Current features**

* Noweb syntax for documents.
* Execute code as terminal or "script" chunks.
* Capture PyPlot or Winston figures.
* Supports latex and pandoc markdown output

**Not implemented**

* Script reader
* Inline code
* Caching

## Chunk options

You can use the same chunk options as for Pweave, but the format is different. Options are separated
using ";" and need to be valid Julia expressions. e.g.


    <<term=true; fig=false>>=


## Usage

Run from julia:

    using JuliaReport
    weave(Pkg.dir("JuliaReport","examples","julia_sample.mdw")

Or using Winston for plots (Julia 0.3 only):

    weave(Pkg.dir("JuliaReport","examples","winston_sample.mdw"),
    plotlib="Winston", doctype="pandoc")


