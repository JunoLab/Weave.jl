
<a id='Using-Weave-1'></a>

# Using Weave


You can write your documentation and code in input document using Noweb or Markdown syntax and use `weave` function to execute to document to capture results and figures.


<a id='Weave-1'></a>

## Weave


Weave document with markup and julia code using Gadfly for plots, `out_path = :pwd` makes the results appear in the current working directory.


```julia
using Weave
weave(Pkg.dir("Weave","examples","gadfly_sample.mdw"), out_path = :pwd)
```


Using PyPlot:


```julia
weave(Pkg.dir("Weave","examples","julia_sample.mdw"), plotlib="PyPlot", out_path = :pwd)
```

<a id='Weave.weave-Tuple{Any}' href='#Weave.weave-Tuple{Any}'>#</a>
**`Weave.weave`** &mdash; *Method*.



`function weave(source ; doctype = :auto, plotlib="Gadfly",         informat=:auto, out_path=:doc, fig_path = "figures", fig_ext = nothing,         cache_path = "cache", cache=:off)`

Weave an input document to output file.

  * `doctype`: :auto = set based on file extension or specify one of the supported formats. See `list_out_formats()`
  * `plotlib`: `"PyPlot"`, `"Gadfly"` or `nothing`
  * `informat`: :auto = set based on file extension or set to  `"noweb"`, `"markdown"` or  `script`
  * `out_path`: Path where the output is generated. Can be: `:doc`: Path of the source document, `:pwd`: Julia working directory, `"somepath"`: output directory as a String e.g `"/home/mpastell/weaveout"` or filename as string e.g. ~/outpath/outfile.tex.
  * `fig_path`: where figures will be generated, relative to out_path
  * `fig_ext`: Extension for saved figures e.g. `".pdf"`, `".png"`. Default setting depends on `doctype`.
  * `cache_path`: where of cached output will be saved.
  * `cache`: controls caching of code: `:off` = no caching, `:all` = cache everything, `:user` = cache based on chunk options, `:refresh`, run all code chunks and save new cache.

**Note:** Run Weave from terminal and not using IJulia, Juno or ESS, they tend to mess with capturing output.


<a id='Weave-from-shell-1'></a>

## Weave from shell


You can also use the `weave.jl` script under bin directory to weave documents from the shell:


```
$ ./weave.jl
usage: weave.jl [--doctype DOCTYPE] [--plotlib PLOTLIB]
                [--informat INFORMAT] [--out_path OUT_PATH]
                [--fig_path FIG_PATH] [--fig_ext FIG_EXT] source...
```


<a id='Tangle-1'></a>

## Tangle


Tangling extracts the code from document:

<a id='Weave.tangle-Tuple{Any}' href='#Weave.tangle-Tuple{Any}'>#</a>
**`Weave.tangle`** &mdash; *Method*.



`tangle(source ; out_path=:doc, informat="noweb")`

Tangle source code from input document to .jl file.

  * `informat`: `"noweb"` of `"markdown"`
  * `out_path`: Path where the output is generated. Can be: `:doc`: Path of the source document, `:pwd`: Julia working directory,  `"somepath"`, directory name as a string e.g `"/home/mpastell/weaveout"`

or filename as string e.g. ~/outpath/outfile.jl.


<a id='Supported-formats-1'></a>

## Supported formats


Weave sets the output format based on the file extension, but you can also set it using `doctype` option. The rules for detecting the format are:


```julia
ext == ".jl" && return "md2html"
contains(ext, ".md") && return "md2html"
contains(ext, ".rst") && return "rst"
contains(ext, ".tex") && return "texminted"
contains(ext, ".txt") && return "asciidoc"
return "pandoc"
```


You can get a list of supported output formats:


```julia
julia> list_out_formats()
pandoc: Pandoc markdown
rst: reStructuredText and Sphinx
texminted: Latex using minted for highlighting
github: Github markdown
md2html: Markdown to HTML (requires Pandoc)
md2pdf: Markdown to pdf (requires Pandoc and xelatex)
asciidoc: AsciiDoc
tex: Latex with custom code environments
```

<a id='Weave.list_out_formats-Tuple{}' href='#Weave.list_out_formats-Tuple{}'>#</a>
**`Weave.list_out_formats`** &mdash; *Method*.



`list_out_formats()`

List supported output formats


<a id='Document-syntax-1'></a>

## Document syntax


Weave uses noweb, markdown or script syntax for defining the code chunks and documentation chunks. You can also weave Jupyter notebooks. The format is detected based on the file extension, but you can also set it manually using the `informat` parameter.


The rules for autodetection are:


```julia
ext == ".jl" && return "script"
ext == ".jmd" && return "markdown"
ext == ".ipynb" && return "notebook"
return "noweb"
```


<a id='Noweb-1'></a>

## Noweb


<a id='Code-chunks-1'></a>

### Code chunks


start with a line marked with `<<>>=` or `<<options>>=` and end with line marked with `@`. The code between the start and end markers is executed and the output is captured to the output document. See for options below.


<a id='Documentation-chunks-1'></a>

### Documentation chunks


Are the rest of the document (between `@` and `<<>>=` lines and the first chunk be default) and can be written with several different markup languages.


[Sample document]( https://github.com/mpastell/Weave.jl/blob/master/examples/julia_sample.mdw)


<a id='Markdown-1'></a>

## Markdown


Markdown code chunks are defined using fenced code blocks. [See sample document:](https://github.com/mpastell/Weave.jl/blob/master/examples/gadfly_md_sample.jmd)

