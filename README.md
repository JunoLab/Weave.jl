# Weave

[![Build Status](https://travis-ci.org/mpastell/Weave.jl.svg?branch=master)](https://travis-ci.org/mpastell/Weave.jl)[![Coverage Status](https://img.shields.io/coveralls/mpastell/Weave.jl.svg)](https://coveralls.io/r/mpastell/Weave.jl?branch=master)

Weave is a scientific report generator/literate programming tool
for Julia. It resembles [Pweave](http://mpastell.com/pweave) and, Knitr
and Sweave.

You can write your documentation and code in input document using Nowed or Markdown syntax and use `weave` function to execute to document to capture results and figures.

**Current features**

* Noweb or markdown syntax for input documents.
* Execute code as terminal or "script" chunks.
* Capture PyPlot, Gadfly figures. (or Winston in  0.0.4)
* Supports LaTex, Pandoc and Github markdown and reStructuredText output

## Usage

Run from julia using Gadfly for plots:

````julia
using Weave
weave(Pkg.dir("Weave","examples","gadfly_sample.mdw"))
````

## Documentation

Documenter.jl with MKDocs generated documentation:

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://mpastell.github.io/Weave.jl/stable/)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://mpastell.github.io/Weave.jl/latest/)

## Contributing

I will probably add new features to Weave when I need them myself or if they are requested and not too difficult to implement. You can contribute by opening issues on Github or implementing things yourself and making a pull request. I'd also appreciate example documents written using Weave to add to examples.

## Contributors

You can see the list of contributors on Github: https://github.com/mpastell/Weave.jl/graphs/contributors. Thanks for the important additions, fixes and comments.
