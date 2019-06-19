var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Weave.jl - Scientific Reports Using Julia",
    "title": "Weave.jl - Scientific Reports Using Julia",
    "category": "page",
    "text": ""
},

{
    "location": "#Weave.jl-Scientific-Reports-Using-Julia-1",
    "page": "Weave.jl - Scientific Reports Using Julia",
    "title": "Weave.jl - Scientific Reports Using Julia",
    "category": "section",
    "text": "This is the documentation of Weave.jl. Weave is a scientific report generator/literate programming tool for Julia. It resembles Pweave, Knitr, rmarkdown and Sweave.Current featuresMarkdown, script of Noweb syntax for input documents\nPublish markdown directly to html and pdf using Julia or Pandoc markdown\nExecute code as terminal or \"script\" chunks\nCapture Plots.jl or  Gadfly.jl figures\nSupports LaTex, Pandoc, Github markdown, MultiMarkdown, Asciidoc and reStructuredText output\nSimple caching of results\nConvert to and from IJulia notebooks(Image: Weave code and output)"
},

{
    "location": "#Contents-1",
    "page": "Weave.jl - Scientific Reports Using Julia",
    "title": "Contents",
    "category": "section",
    "text": "Pages = [\"getting_started.md\", \"usage.md\",\n\"publish.md\", \"chunk_options.md\", \"notebooks.md\",\n\"function_index.md\"]"
},

{
    "location": "getting_started/#",
    "page": "Getting started",
    "title": "Getting started",
    "category": "page",
    "text": ""
},

{
    "location": "getting_started/#Getting-started-1",
    "page": "Getting started",
    "title": "Getting started",
    "category": "section",
    "text": "The best way to get started using Weave.jl is to look at the example input and output documents. Examples for different formats are included in the packages examples directory.First have a look at source document using markdown code chunks and Plots.jl for figures: FIR_design.jmd and then see the output in different formats:HTML: FIR_design.html\npdf: FIR_design.pdf\nPandoc markdown: FIR_design.txtProducing pdf output requires that you have XeLateX installed.Add dependencies for the example if needed:using Pkg; Pkg.add.([\"Plots\", \"DSP\"])Weave the files to your working directory using:using Weave\n#HTML\nweave(joinpath(dirname(pathof(Weave)), \"../examples\", \"FIR_design.jmd\"),\n  out_path=:pwd,\n  doctype = \"md2html\")\n#pdf\nweave(joinpath(dirname(pathof(Weave)), \"../examples\", \"FIR_design.jmd\"),\n  out_path=:pwd,\n  doctype = \"md2pdf\")\n  #Markdown\nweave(joinpath(dirname(pathof(Weave)), \"../examples\", \"FIR_design.jmd\"),\n      doctype=\"pandoc\"\n      out_path=:pwd)"
},

{
    "location": "usage/#",
    "page": "Using Weave",
    "title": "Using Weave",
    "category": "page",
    "text": ""
},

{
    "location": "usage/#Using-Weave-1",
    "page": "Using Weave",
    "title": "Using Weave",
    "category": "section",
    "text": "You can write your documentation and code in input document using Markdown, Noweb or script syntax and use weave function to execute to document to capture results and figures."
},

{
    "location": "usage/#Weave.weave-Tuple{Any}",
    "page": "Using Weave",
    "title": "Weave.weave",
    "category": "method",
    "text": "weave(source ; doctype = :auto,\n    informat=:auto, out_path=:doc, args = Dict(),\n    mod::Union{Module, Symbol} = Main,\n    fig_path = \"figures\", fig_ext = nothing,\n    cache_path = \"cache\", cache=:off,\n    template = nothing, highlight_theme = nothing, css = nothing,\n    pandoc_options = \"\",\n    latex_cmd = \"xelatex\")\n\nWeave an input document to output file.\n\ndoctype: :auto = set based on file extension or specify one of the supported formats. See list_out_formats()\ninformat: :auto = set based on file extension or set to  \"noweb\", \"markdown\" or  script\nout_path: Path where the output is generated. Can be: :doc: Path of the source document, :pwd:  Julia working directory, \"somepath\": output directory as a String e.g \"/home/mpastell/weaveout\" or filename as  string e.g. ~/outpath/outfile.tex.\nargs: dictionary of arguments to pass to document. Available as WEAVE_ARGS\nmod: Module where Weave evals code. Defaults to :sandbox  to create new sandbox module, you can also pass a module e.g. Main.\nfig_path: where figures will be generated, relative to out_path\nfig_ext: Extension for saved figures e.g. \".pdf\", \".png\". Default setting depends on doctype.\ncache_path: where of cached output will be saved.\ncache: controls caching of code: :off = no caching, :all = cache everything, :user = cache based on chunk options, :refresh, run all code chunks and save new cache.\nthrow_errors if false errors are included in output document and the whole document is   executed. if true errors are thrown when they occur.\ntemplate : Template (file path) or MustacheTokens for md2html or md2tex formats.\nhighlight_theme : Theme (Highlights.AbstractTheme) for used syntax highlighting\ncss : CSS (file path) used for md2html format\npandoc_options = String array of options to pass to pandoc for pandoc2html and  pandoc2pdf formats e.g. [\"–toc\", \"-N\"]\nlatex_cmd the command used to make pdf from .tex\n\nNote: Run Weave from terminal and not using IJulia, Juno or ESS, they tend to mess with capturing output.\n\n\n\n\n\n"
},

{
    "location": "usage/#Weave-1",
    "page": "Using Weave",
    "title": "Weave",
    "category": "section",
    "text": "Weave document with markup and julia code using Plots.jl for plots, out_path = :pwd makes the results appear in the current working directory.#First add depencies for the example\nusing Pkg; Pkg.add.([\"Plots\", \"DSP\"])\nusing Weave\nweave(joinpath(dirname(pathof(Weave)), \"../examples\", \"FIR_design.jmd\"), out_path=:pwd)weave(source)"
},

{
    "location": "usage/#Weave.tangle-Tuple{Any}",
    "page": "Using Weave",
    "title": "Weave.tangle",
    "category": "method",
    "text": "tangle(source ; out_path=:doc, informat=\"noweb\")\n\nTangle source code from input document to .jl file.\n\ninformat: \"noweb\" of \"markdown\"\nout_path: Path where the output is generated. Can be: :doc: Path of the source document, :pwd: Julia working directory,  \"somepath\", directory name as a string e.g \"/home/mpastell/weaveout\"\n\nor filename as string e.g. ~/outpath/outfile.jl.\n\n\n\n\n\n"
},

{
    "location": "usage/#Tangle-1",
    "page": "Using Weave",
    "title": "Tangle",
    "category": "section",
    "text": "Tangling extracts the code from document:tangle(source)"
},

{
    "location": "usage/#Weave.list_out_formats-Tuple{}",
    "page": "Using Weave",
    "title": "Weave.list_out_formats",
    "category": "method",
    "text": "list_out_formats()\n\nList supported output formats\n\n\n\n\n\n"
},

{
    "location": "usage/#Supported-output-formats-1",
    "page": "Using Weave",
    "title": "Supported output formats",
    "category": "section",
    "text": "Weave sets the output format based on the file extension, but you can also set it using doctype option. The rules for detecting the format are:ext == \".jl\" && return \"md2html\"\ncontains(ext, \".md\") && return \"md2html\"\ncontains(ext, \".rst\") && return \"rst\"\ncontains(ext, \".tex\") && return \"texminted\"\ncontains(ext, \".txt\") && return \"asciidoc\"\nreturn \"pandoc\"You can get a list of supported output formats:using Weave # hide\nlist_out_formats()list_out_formats()"
},

{
    "location": "usage/#Document-syntax-1",
    "page": "Using Weave",
    "title": "Document syntax",
    "category": "section",
    "text": "Weave uses markdown, Noweb or script syntax for defining the code chunks and documentation chunks. You can also weave Jupyter notebooks. The format is detected based on the file extension, but you can also set it manually using the informat parameter.The rules for autodetection are:ext == \".jl\" && return \"script\"\next == \".jmd\" && return \"markdown\"\next == \".ipynb\" && return \"notebook\"\nreturn \"noweb\""
},

{
    "location": "usage/#Documentation-chunks-1",
    "page": "Using Weave",
    "title": "Documentation chunks",
    "category": "section",
    "text": "In Markdown and Noweb input formats documentation chunks are the parts that aren\'t inside code delimiters. Documentation chunks can be written with several different markup languages."
},

{
    "location": "usage/#Code-chunks-1",
    "page": "Using Weave",
    "title": "Code chunks",
    "category": "section",
    "text": ""
},

{
    "location": "usage/#Markdown-format-1",
    "page": "Using Weave",
    "title": "Markdown format",
    "category": "section",
    "text": "Markdown code chunks are defined using fenced code blocks with options following on the same line. e.g. to hide code from output you can use: ```julia; echo=false`Sample document"
},

{
    "location": "usage/#Inline-code-1",
    "page": "Using Weave",
    "title": "Inline code",
    "category": "section",
    "text": "You can also add inline code to your documents using`j juliacode`or! juliacodesyntax. Using the j code syntax you can insert code anywhere in a line and with   the ! syntax the whole line after ! will be executed. The code will be replaced with captured output in the weaved document.If the code produces figures the filename or base64 encoded string will be added to output e.g. to include a Plots figure in markdown you can use:![A plot](`j plot(1:10)`)or to produce any html output:! display(\"text/html\", \"Header from julia\");"
},

{
    "location": "usage/#Noweb-format-1",
    "page": "Using Weave",
    "title": "Noweb format",
    "category": "section",
    "text": "Code chunks start with a line marked with <<>>= or <<options>>= and end with line marked with @. The code between the start and end markers is executed and the output is captured to the output document. See chunk options."
},

{
    "location": "usage/#Script-format-1",
    "page": "Using Weave",
    "title": "Script format",
    "category": "section",
    "text": "Weave also support script input format with a markup in comments. These scripts can be executed normally using Julia or published with Weave.  Documentation is in lines starting with #\', #%% or # %%, and code is executed and results are included in the weaved document.All lines that are not documentation are treated as code. You can set chunk options using lines starting with #+ just before code e.g. #+ term=true.The format is identical to Pweave and the concept is similar to publishing documents with MATLAB or using Knitr\'s spin. Weave will remove the first empty space from each line of documentation.See sample document:"
},

{
    "location": "usage/#Setting-document-options-in-header-1",
    "page": "Using Weave",
    "title": "Setting document options in header",
    "category": "section",
    "text": "You can use a YAML header in the beginning of the input document delimited with \"–-\" to set the document title, author and date e.g. and default document options. Each of Weave command line arguments and chunk options can be set in header using options field. Below is an example that sets document out_path and doctype using the header.---\ntitle : Weave example\nauthor : Matti Pastell\ndate: 15th December 2016\noptions:\n  out_path : reports/example.md\n  doctype :  github\n---You can also set format specific options. Here is how to set different out_path for md2html and md2pdf and set fig_ext for both:---\noptions:\n    md2html:\n        out_path : html\n    md2pdf:\n        out_path : pdf\n    fig_ext : .png\n---"
},

{
    "location": "usage/#Passing-arguments-to-documents-1",
    "page": "Using Weave",
    "title": "Passing arguments to documents",
    "category": "section",
    "text": "You can pass arguments as dictionary to the weaved document using the args argument to weave. The dictionary will be available as WEAVE_ARGS variable in the document.This makes it possible to create the same report easily for e.g. different date ranges of input data from a database or from files with similar format giving the filename as input.In order to pass a filename to a document you need call weave using:weave(\"mydoc.jmd\", args = Dict(\"filename\" => \"somedata.h5\"))and you can access the filename from document as follows: ```julia\n print(WEAVE_ARGS[\"filename\"])\n ```You can use the out_path argument to control the name of the output document."
},

{
    "location": "usage/#Include-Weave-document-in-Julia-1",
    "page": "Using Weave",
    "title": "Include Weave document in Julia",
    "category": "section",
    "text": "You can call include_weave on a Weave document to run the contents of all code chunks in Julia.include_weave(doc, informat=:auto)"
},

{
    "location": "publish/#",
    "page": "Publishing to html and pdf",
    "title": "Publishing to html and pdf",
    "category": "page",
    "text": ""
},

{
    "location": "publish/#Publishing-to-html-and-pdf-1",
    "page": "Publishing to html and pdf",
    "title": "Publishing to html and pdf",
    "category": "section",
    "text": "You can also publish any supported input format using markdown for doc chunks to html and pdf documents. Producing pdf output requires that you have pdflatex installed and in your path.You can use a YAML header in the beginning of the input document delimited with \"–-\" to set the document title, author and date e.g.---\ntitle : Weave example\nauthor : Matti Pastell\ndate: 15th December 2016\n---Here is a a sample document and output:FIRdesignplots.jl, FIRdesignplots.html , FIRdesignplots.pdf.weave(\"FIR_design_plots.jl\")\nweave(\"FIR_design_plots.jl\", docformat = \"md2pdf\")Note: docformats md2pdf and md2html use Julia markdown and pandoc2pdf and pandoc2html use Pandoc."
},

{
    "location": "publish/#Templates-1",
    "page": "Publishing to html and pdf",
    "title": "Templates",
    "category": "section",
    "text": "You can use a custom template with md2pdf and md2html formats with template argument (e.g) weave(\"FIR_design_plots.jl\", template = \"custom.tpl\"). You can use the existing templates as starting point.For HTML: julia_html.tpl and LaTex: julia_tex.tplTemplates are rendered using Mustache.jl."
},

{
    "location": "publish/#Supported-Markdown-syntax-1",
    "page": "Publishing to html and pdf",
    "title": "Supported Markdown syntax",
    "category": "section",
    "text": "The markdown variant used by Weave is Julia markdown. In addition Weave supports few additional Markdown features:CommentsYou can add comments using html syntax: <!-- -->Multiline equationsYou can add multiline equations using:$$\nx^2 = x*x\n$$"
},

{
    "location": "chunk_options/#",
    "page": "Chunk options",
    "title": "Chunk options",
    "category": "page",
    "text": ""
},

{
    "location": "chunk_options/#Chunk-options-1",
    "page": "Chunk options",
    "title": "Chunk options",
    "category": "section",
    "text": "I\'ve mostly followed Knitr\'s naming for chunk options, but not all options are implemented.Options are separated using \";\" and need to be valid Julia expressions. Example: markdown code chunk that saves and displays a 12 cm wide image and hides the source code:julia; out_width=\"12cm\"; echo=falseWeave currently supports the following chunk options with the following defaults:"
},

{
    "location": "chunk_options/#Options-for-code-1",
    "page": "Chunk options",
    "title": "Options for code",
    "category": "section",
    "text": "echo = true. Echo the code in the output document. If false the source code will be hidden.\nresults = \"markup\". The output format of the printed results. \"markup\" for literal block, \"hidden\" for hidden results or anything else for raw output (I tend to use ‘tex’ for Latex and ‘rst’ for rest. Raw output is useful if you wan’t to e.g. create tables from code chunks.\neval = true. Evaluate the code chunk. If false the chunk won’t be executed.\nterm=false. If true the output emulates a REPL session. Otherwise only stdout and figures will be included in output.\nlabel. Chunk label, will be used for figure labels in Latex as fig:label\nwrap = true. Wrap long lines from output.\nline_width = 75. Line width for wrapped lines.\ncache = false. Cache results, depends on cache parameter on weave function.\nhold = false. Hold all results until the end of the chunk.\ntangle = true. Set tangle to false to exclude chunk from tangled code."
},

{
    "location": "chunk_options/#Options-for-figures-1",
    "page": "Chunk options",
    "title": "Options for figures",
    "category": "section",
    "text": "fig_width. Figure width passed to plotting library e.g. 800\nfig_height Figure height passed to plotting library\nout_width. Width of saved figure in output markup e.g. \"50%\", \"12cm\", \\\\0.5linewidth\nout_height. Height of saved figure in output markup\ndpi=96. Resolution of saved figures.\nfig_cap. Figure caption.\nlabel. Chunk label, will be used for figure labels in Latex as fig:label\nfig_ext. File extension (format) of saved figures.\nfig_pos=\"htpb\". Figure position in Latex.  \nfig_env=\"figure\". Figure environment in Latex."
},

{
    "location": "chunk_options/#Set-default-chunk-options-1",
    "page": "Chunk options",
    "title": "Set default chunk options",
    "category": "section",
    "text": "You can set the default chunk options (and weave arguments) for a document using the YAML header options field. e.g to set the default out_width of all figures you can use:---\noptions:\n      out_width : 50%\n---You can also set or change the default chunk options for a document either before weave using the set_chunk_defaults function.set_chunk_defaults(opts)\nget_chunk_defaults()\nrestore_chunk_defaults()"
},

{
    "location": "notebooks/#",
    "page": "Working with Jupyter notebooks",
    "title": "Working with Jupyter notebooks",
    "category": "page",
    "text": ""
},

{
    "location": "notebooks/#Working-with-Jupyter-notebooks-1",
    "page": "Working with Jupyter notebooks",
    "title": "Working with Jupyter notebooks",
    "category": "section",
    "text": ""
},

{
    "location": "notebooks/#Weaving-from-Jupyter-notebooks-1",
    "page": "Working with Jupyter notebooks",
    "title": "Weaving from Jupyter notebooks",
    "category": "section",
    "text": "Weave supports using Jupyter notebooks as input format, this means you can weave notebooks to any supported formats. You can\'t use chunk options with notebooks.weave(\"notebook.ipynb\")"
},

{
    "location": "notebooks/#Output-to-Jupyter-notebooks-1",
    "page": "Working with Jupyter notebooks",
    "title": "Output to Jupyter notebooks",
    "category": "section",
    "text": "As of Weave 0.5.1. there is new notebook method to convert Weave documents to Jupyter notebooks using nbconvert. The code is not executed by Weave and the output doesn\'t always work properly, see #116.notebook(source::String, out_path=:pwd)You might want to use the convert_doc method below instead and run the code in Jupyter.You can select the jupyter used to execute the notebook with the jupyter_path argument (this defaults to the string \"jupyter,\" i.e., whatever you have linked to that location.)"
},

{
    "location": "notebooks/#Weave.convert_doc-Tuple{String,String}",
    "page": "Working with Jupyter notebooks",
    "title": "Weave.convert_doc",
    "category": "method",
    "text": "convert_doc(infile::AbstractString, outfile::AbstractString; format = nothing)\n\nConvert Weave documents between different formats\n\ninfile = Name of the input document\noutfile = Name of the output document\nformat = Output format (optional). Detected from outfile extension, but can be set to \"script\", \"markdown\", \"notebook\" or \"noweb\".\n\n\n\n\n\n"
},

{
    "location": "notebooks/#Converting-between-formats-1",
    "page": "Working with Jupyter notebooks",
    "title": "Converting between formats",
    "category": "section",
    "text": "You can convert between all supported input formats using the convert_doc function.To convert from script to notebook:convert_doc(\"examples/FIR_design.jl\", \"FIR_design.ipynb\")and from notebooks to markdown use:convert_doc(\"FIR_design.ipynb\", \"FIR_design.jmd\")convert_doc(infile::String, outfile::String)"
},

{
    "location": "function_index/#",
    "page": "Function index",
    "title": "Function index",
    "category": "page",
    "text": ""
},

{
    "location": "function_index/#Function-index-1",
    "page": "Function index",
    "title": "Function index",
    "category": "section",
    "text": ""
},

]}
