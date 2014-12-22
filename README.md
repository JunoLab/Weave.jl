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

Run from julia using Gadfly for plots:

````julia
using Weave
weave(Pkg.dir("Weave","examples","gadfly_sample.mdw"))
````

Using Winston for plots (Julia 0.3 only):

````julia
weave(Pkg.dir("Weave","examples","winston_sample.mdw"),
plotlib="Winston", doctype="pandoc")
````

Using PyPlot:

````julia
weave(Pkg.dir("Weave","examples","julia_sample.mdw"), plotlib="PyPlot")
````

The signature of weave functions is:

````julia
function weave(source ; doctype = "pandoc", plotlib="Gadfly", informat="noweb", out_path=:doc, fig_path = "figures", fig_ext = nothing)
````
* `doctype`: see `list_out_formats()`
* `plotlib`: `"PyPlot"`, `"Gadfly"`, or `"Winston"`
* `informat`: `"noweb"` of `"markdown"`
* `out_path`: Path where the output is generated:
    - `:doc`: Path of the source document.
    - `:pwd`: Julia working directory
    - `"somepath"`: Path as a string e.g `"/home/mpastell/weaveout"`
* `fig_path`: where figures will be generated, relative to out_path
* `fig_ext`: Extension for saved figures e.g. `".pdf"`, `".png"`. Default setting depends on `doctype`.

**Note:** Run Weave from terminal and not using IJulia, Juno or ESS, they tend to mess with capturing output.

## Contributing

I will probably add new features to Weave when I need them myself or if they are requested and not too difficult to implement. You can contribute by opening issues on Github or implementing things yourself and making a pull request. I'd also appreciate example documents written using Weave to add to examples.

## Contributors

You can see the list of contributors on Github: https://github.com/mpastell/Weave.jl/graphs/contributors. Thanks for the important additions, fixes and comments.
