# Weave

[![Build Status](https://travis-ci.org/mpastell/Weave.jl.svg?branch=master)](https://travis-ci.org/mpastell/Weave.jl)[![Coverage Status](https://img.shields.io/coveralls/mpastell/Weave.jl.svg)](https://coveralls.io/r/mpastell/Weave.jl?branch=master)

Weave is a scientific report generator/literate programming tool
for Julia. It resembles [Pweave](http://mpastell.com/pweave) and, Knitr
and Sweave.


**Current features**

* Noweb or markdown syntax for input documents.
* Execute code as terminal or "script" chunks.
* Capture PyPlot, Gadfly or Winston figures.
* Supports LaTex, Pandoc and Github markdown and reStructuredText output

**Not implemented**

* Script reader
* Inline code
* Caching

## Chunk options

I've tried to follow [Knitr](http://yihui.name/knitr/options)'s naming for chunk options, but not all options are implemented.
You can see [`src/config.jl`](https://github.com/mpastell/Weave.jl/blob/master/src/config.jl) for the current situation.

Options are separated using ";" and need to be valid Julia expressions. e.g.

    <<term=true; fig_width=6; fig_height=4>>=

## File formats

You can get a list of supported output formats:

````julia
julia> list_out_formats()
pandoc: Pandoc markdown
rst: reStructuredText and Sphinx
texminted: Latex using minted for highlighting
github: Github markdown
tex: Latex with custom code environments
````


## Usage

Run from julia:

````julia
using Weave
weave(Pkg.dir("Weave","examples","julia_sample.mdw")
````

Using Winston for plots (Julia 0.3 only):

````julia
weave(Pkg.dir("Weave","examples","winston_sample.mdw"),
plotlib="Winston", doctype="pandoc")
````

Using Gadfly (Julia 0.3 only):

````julia
weave(Pkg.dir("Weave","examples","gadfly_sample.mdw"), plotlib="Gadfly")
````

The signature of weave functions is:

````julia
function weave(source ; doctype = "pandoc",
    plotlib="PyPlot", informat="noweb", fig_path = "figures", fig_ext = nothing)
````

**Note:** Run Weave from terminal and not using IJulia, Juno or ESS, they tend to mess with capturing output.

## Contributing

I will probably add new features to Weave when I need them myself or if they are requested and not too difficult to implement. You can contribute by opening issues on Github or implementing things yourself and making a pull request. I'd also appreciate example documents written using Weave to add to examples.

## Contributors

Douglas Bates has contributed a number of important fixes and comments.
