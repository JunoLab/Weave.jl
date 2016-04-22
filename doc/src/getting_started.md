
# Getting started

The best way to get started using Weave.jl is to look at the example input and
output documents. Examples for different formats are included in the packages `examples` directory.

First have a look at source document using markdown code chunks and Gadfly for
figures: [gadfly_md_sample.jmd](examples/gadfly_md_sample.jmd) and then see the
output in different formats:

  - Pandoc markdown: [gadfly_md_sample.md](examples/gadfly_md_sample.txt)
  - HTML: [gadfly_md_sample.html](examples/gadfly_md_sample.html)
  - pdf: [gadfly_md_sample.pdf](examples/gadfly_md_sample.pdf)

*Producing HTML and pdf output requires that you have Pandoc and XeLatex (for pdf) installed.*

You can Weave the files to your working directory using:

```
using Weave
#Markdown
weave(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"), out_path = :pwd,
  doctype = "pandoc")
#HTML
weave(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"), out_path = :pwd,
  doctype = "md2html")
#pdf
weave(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"), out_path = :pwd,
  doctype = "md2pdf")
```
