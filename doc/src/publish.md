# Publishing scripts

You can also also publish html and pdf
documents from Julia scripts with a specific format. Producing HTML and pdf output
requires that you have Pandoc and XeLatex (for pdf) installed and in your path.

These scripts can be executed normally using Julia or published with Weave.
Documentation is written in markdown in lines starting with `#'`, `#%%` or `# %%`,
and code is executed and results are included in the published document.

The format is identical to [Pweave](http://mpastell.com/pweave/pypublish.html)
and the concept is similar to publishing documents with MATLAB or
using Knitr's [spin](http://yihui.name/knitr/demo/stitch/).
Weave will remove the first empty space from each line of documentation.

All lines that are not documentation are treated as code. You can set chunk options
using lines starting with `#+` just before code
e.g. `#+ term=true`. See the example below for the markup.


[FIR_design.jl](examples/FIR_design.jl), [FIR_design.html](examples/FIR_design.html) , [FIR_design.pdf](examples/FIR_design.pdf).

```
weave("FIR_design.jl")
weave("FIR_design.jl", docformat = "md2pdf")
```

## Other mark ups with scripts

You can also use any Weave supported format in the comments and set the output format
as you would for noweb and markdown inputs. e.g for LaTeX you can use:

```
weave("latex_doc.jl", docformat = "texminted")
```
