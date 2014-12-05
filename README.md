# JuliaReport

[![Build Status](https://travis-ci.org/mpastell/JuliaReport.jl.svg?branch=master)](https://travis-ci.org/mpastell/JuliaReport.jl)

JuliaReport is a scientific report generator/literate programming tool
for Julia. It resembles [Pweave](http://mpastell.com/pweave) and, Knitr
and Sweave.


**Current features**

* Noweb syntax for documents.
* Execute code as terminal or "script" chunks.
* Capture PyPlot, Gadfly or Winston figures.
* Supports latex and pandoc markdown output

**Not implemented**

* Script reader
* Inline code
* Caching

## Chunk options

I've tried to follow [Knitr](http://yihui.name/knitr/options)'s naming for chunk options, but not all options are implemented.
You can see [`src/config.jl`](https://github.com/mpastell/JuliaReport.jl/blob/master/src/config.jl) for the current situation.

Options are separated using ";" and need to be valid Julia expressions. e.g.

    <<term=true; fig_width=6; fig_height=4>>=


## Usage

Run from julia:

    using JuliaReport
    weave(Pkg.dir("JuliaReport","examples","julia_sample.mdw")

Using Winston for plots (Julia 0.3 only):

    weave(Pkg.dir("JuliaReport","examples","winston_sample.mdw"),
    plotlib="Winston", doctype="pandoc")

Using Gadfly (Julia 0.3 only):

    weave(Pkg.dir("JuliaReport","examples","gadfly_sample.mdw"), plotlib="Gadfly")

The signature of weave functions is:

    function weave(source ; doctype = "pandoc", plotlib="PyPlot", informat="noweb", fig_path = "figures", fig_ext = nothing)

**Note:** Run JuliaReport from terminal and not using IJulia, Juno or ESS, they tend to mess with capturing output.

## Contributing

I will probably add new features to JuliaReport when I need them myself or if they are requested and not too difficult to implement. You can contribute by opening issues on Github or implementing things yourself and making a pull request. I'd also appreciate example documents written using JuliaReport to add to examples.

## Contributors

Douglas Bates has contributed a number of important fixes and comments.
