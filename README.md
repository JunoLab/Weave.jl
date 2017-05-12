# Weave

[![Build Status](https://travis-ci.org/mpastell/Weave.jl.svg?branch=master)](https://travis-ci.org/mpastell/Weave.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/r97pwi9x8ard6xk6/branch/master?svg=true)](https://ci.appveyor.com/project/mpastell/weave-jl/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/mpastell/Weave.jl.svg)](https://coveralls.io/r/mpastell/Weave.jl?branch=master)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://mpastell.github.io/Weave.jl/stable)
[![](http://joss.theoj.org/papers/10.21105/joss.00204/status.svg)](http://dx.doi.org/10.21105/joss.00204)

Weave is a scientific report generator/literate programming tool
for Julia. It resembles [Pweave](http://mpastell.com/pweave), Knitr, rmarkdown
and Sweave.

You can write your documentation and code in input document using Noweb,
Markdown, Script syntax and use `weave` function to execute to document to capture results
and figures.

**Current features**

* Noweb, markdown or script syntax for input documents.
* Execute code as terminal or "script" chunks.
* Capture Plots, Gadfly and PyPlot figures.
* Supports LaTex, Pandoc, Github markdown, MultiMarkdown, Asciidoc and reStructuredText output
* Publish markdown directly to html and pdf using Julia or Pandoc markdown.
* Simple caching of results
* Convert to and from IJulia notebooks

**Citing Weave:** *Pastell, Matti. 2017. Weave.jl: Scientific Reports Using Julia. The Journal of Open Source Software. http://dx.doi.org/10.21105/joss.00204*


**Note about Julia 0.6**: Weave has been updated to support 0.6, current master
requires using `Compat` master (`Compat.invokelatest`). PyPlot, Gadfly and Plots now
also work (12th May 2017).

![Weave code and output](http://mpastell.com/images/weave_demo.png)

## Installation

You can install the latest release using Julia package manager:

```julia
Pkg.add("Weave")
```

## Usage

Run from julia using Gadfly for plots:

```julia
#First add depencies for the example
Pkg.add.(["Cairo", "Fontconfig", "Gadfly"])
#Use Weave
using Weave
weave(Pkg.dir("Weave","examples","gadfly_sample.mdw"))
```

If you have Pandoc installed you can also weave directly to html and pdf.

```julia
weave(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"), informat="markdown",
  out_path = :pwd, doctype = "md2html")
```

## Documentation

Documenter.jl with MKDocs generated documentation:

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://mpastell.github.io/Weave.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://mpastell.github.io/Weave.jl/latest)

## Editor support

I have made [language-weave](https://atom.io/packages/language-weave) package
for Atom to do the syntax highlighting correctly.

Noweb documents work well with ESS as well, to set doc-mode for .mdw files to markdown
and code to Julia you can do:

```clojure
(defun mdw-mode ()
       (ess-noweb-mode)
       (setq ess-noweb-default-code-mode 'ess-julia-mode)
       (setq ess-noweb-doc-mode 'markdown-mode))

(setq auto-mode-alist (append (list (cons "\\.mdw$" 'mdw-mode))
                   auto-mode-alist))
```


## Contributing

I will probably add new features to Weave when I need them myself or if they are requested and not too difficult to implement. You can contribute by opening issues on Github or implementing things yourself and making a pull request. I'd also appreciate example documents written using Weave to add to examples.

## Contributors

You can see the list of contributors on Github: https://github.com/mpastell/Weave.jl/graphs/contributors. Thanks for the important additions, fixes and comments.
