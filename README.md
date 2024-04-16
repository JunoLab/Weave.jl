# Weave

![CI](https://github.com/JunoLab/Weave.jl/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/JunoLab/Weave.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JunoLab/Weave.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](http://weavejl.mpastell.com/stable/)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](http://weavejl.mpastell.com/dev/)
[![](http://joss.theoj.org/papers/10.21105/joss.00204/status.svg)](http://dx.doi.org/10.21105/joss.00204)

Weave is a scientific report generator/literate programming tool for the [Julia programming language](https://julialang.org/).
It resembles
[Pweave](http://mpastell.com/pweave),
[knitr](https://yihui.org/knitr/),
[R Markdown](https://rmarkdown.rstudio.com/),
and [Sweave](https://stat.ethz.ch/R-manual/R-patched/library/utils/doc/Sweave.pdf).

You can write your documentation and code in input document using Markdown, Noweb or ordinal Julia script syntax,
and then use `weave` function to execute code and generate an output document while capturing results and figures.

**Current features**

- Publish markdown directly to HTML and PDF using Julia or [Pandoc](https://pandoc.org/MANUAL.html)
- Execute code as in terminal or in a unit of code chunk
- Capture [Plots.jl](https://github.com/JuliaPlots/Plots.jl) or [Gadfly.jl](https://github.com/GiovineItalia/Gadfly.jl) figures
- Supports various input format: Markdown, [Noweb](https://www.cs.tufts.edu/~nr/noweb/), [Jupyter Notebook](https://jupyter.org/), and ordinal Julia script
- Conversions between those input formats
- Supports various output document formats: HTML, PDF, GitHub markdown, Jupyter Notebook, MultiMarkdown, Asciidoc and reStructuredText
- Simple caching of results

**Citing Weave:** *Pastell, Matti. 2017. Weave.jl: Scientific Reports Using Julia. The Journal of Open Source Software. http://dx.doi.org/10.21105/joss.00204*

![Weave in Juno demo](https://user-images.githubusercontent.com/40514306/76081328-32f41900-5fec-11ea-958a-375f77f642a2.png)


## Installation

You can install the latest release using Julia package manager:

```julia
using Pkg
Pkg.add("Weave")
```


## Usage

```julia
using Weave

# add depencies for the example
using Pkg; Pkg.add(["Plots", "DSP"])

filename = normpath(Weave.EXAMPLE_FOLDER, "FIR_design.jmd")
weave(filename, out_path = :pwd)
```

If you have LaTeX installed you can also weave directly to pdf.

```julia
filename = normpath(Weave.EXAMPLE_FOLDER, "FIR_design.jmd")
weave(filename, out_path = :pwd, doctype = "md2pdf")
```

NOTE: `Weave.EXAMPLE_FOLDER` just points to [`examples` directory](./examples).


## Documentation

Documenter.jl with MKDocs generated documentation:

[![](https://img.shields.io/badge/docs-stable-blue.svg)](http://weavejl.mpastell.com/stable/)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](http://weavejl.mpastell.com/dev/)


## Editor support

Install [language-weave](https://atom.io/packages/language-weave) to add Weave support to Juno.
It allows running code from Weave documents with usual keybindings and allows preview of
html and pdf output.

The [Julia extension for Visual Studio Code](https://www.julia-vscode.org/)
adds Weave support to [Visual Studio Code](https://code.visualstudio.com/).


## Contributing

You can contribute to this package by opening issues on GitHub or implementing things yourself and making a pull request.
We'd also appreciate more example documents written using Weave.


## Contributors

You can see the list of contributors on GitHub: https://github.com/JunoLab/Weave.jl/graphs/contributors .
Thanks for the important additions, fixes and comments.


## Example projects using Weave

- [DiffEqTutorials.jl](https://github.com/JuliaDiffEq/DiffEqTutorials.jl) uses Weave to output tutorials (`.jmd` documents) to html, pdf and Jupyter notebooks.
- [TuringTutorials](https://github.com/TuringLang/TuringTutorials) uses Weave to convert notebooks to html.

## Related packages

- [Literate.jl](https://github.com/fredrikekre/Literate.jl) can be used to generate Markdown and Jupyter notebooks directly from Julia source files with markdown in comments.
- [Quarto](https://quarto.org) can generate Jupyter notebooks, HTML, or PDF directly from a Markdown format containing Julia code blocks, and also works with R and Python.
