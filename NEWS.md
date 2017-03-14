
# Release notes for Weave.jl

### v0.4.1
* Disable precompilation due to warnings from depencies
* Fix deprecation warnings for Julia 0.6
* Fix PyPlot for Julia 0.6
* Support citations in `pandoc2html` and `pandoc2pdf` output
* Fix extra whitespace when `term=true`
* Fix mime type priority for `md2html`

### V0.4.0
* Support passing arguments to document using `args` option
* Add `include_weave` for including code from Weave documents
* Add support for inline code chunks
* Remove generated figure files when publishing to html and pdf

### v0.3.0

* Add support for YAML title block
* Use Julia markdown for publishing to pdf and html
* Add `template`, `highlight_theme`, `latex_cmd` and `css` option to `weave` for customizing html and pdf output
* Bug fixes
  * Fix plotting on Windows
  * Fix extra whitespace from code chunk output
* Improved GR and GLVisualize support with Plots

### v0.2.2

* Add IJulia notebook as input format
* Add `convert_doc` method to convert between input formats

### v0.2.1

* Fix critical hanging on Windows using proper handling of redirect_stdout
* Add support for Plots.jl plotly and plotlyjs backends for including javascipt
  output in published HTML documents.
* Fix semicolons for `term=true`

### v0.2

* Move to Julia 0.5 only
* New `display` and `prompt` chunk options by @gragusa
* Implemented fig_width and fig_height chunk option for Plots.jl
* Added pre and post chunk hooks, only used internally for now
* Automatic detection of plotting library, `:auto` is the new default options
* Support for displaying general multimedia objects e.g. Plots.jl and Images.jl
  now work with weave.
* Support for including html, latex and markdown output from objects
* New logic for displaying output in script chunks, output is shown by default for:
  - Writing to stdout
  - Calling display
  - Gadfly plots
  - Variables on their own
  - If the last line of a chunk is a function call that returns output e.g. plot(1:10)
* Bug fixes
  - Fix parsing of lone variables from chunks
  - Fix error with md2html formatter and dates #38

### v0.1.2

27th April 2016

* Fix a bug with `out_path` for md2html and md2pdf
* Fix md2html and md2pdf on Windows
* Improve doctype autodetection
* Improved regex for parsing markdown input format

### v0.1.1

* Change pandoc output to use inline images if there is no caption.
* Use Documenter.jl for documentation.
* Add chunk option `hold`, replaces results = "hold". This way you can use e.g. `hold = true, results=raw`.
* Methods for setting and restoring default chunk options for documents.
* New output options `md2pdf` and `md2html`, both use pandoc to output pdf
  and html files directly with own templates.
* Restored and improved Winston support.
* New input format: scripts with markup in comments
* New output format: MultiMarkdown
* Added support for figure width in Pandoc
* Autodetect input and output formats based on filename
* Allow `out_path` be a file or directory.

### v0.1.0

19th April 2016

* Updated for Julia 0.4x, drop 0.3x support
* Each document is executed in separate sandbox module instead of redefining the same one. Fixes warnings and occasional segfaults.
* Change the output of chunks:
  - Output will be added to the output directly where they are created (default).
  - Use results = "hold" to push all output after the chunk.
* New chunk option: `line_width`.
* Winston support is not implemented yet for this version.
* Bug fix in wrapping output lines.
* Internal changes
    - Chunks are now represented with their own type. Allows multiple dispatch
      and easier implementation of new chunks.

### 0.0.4

4th January 2015

* Added AsciiDoc formatter
* Default plotting library changed to Gadfly
* New option: `out_path` for controlling where weaved documents and figures are saved
* Command line script `bin/weave.jl` for calling weave from command line

### 0.0.3

9th December 2014

* Sandbox module for running code is cleared between documents
* Fixed Latex figure handling (with contributions from @wildart)
* Changed "tex" format: separate environment for term chunks
* Improved test coverage
* Fixed a bug with eval=false chunk option.


### 0.0.2

7th December 2014

* First release
    * Noweb and markdown input formats
    * Support for Gadfly, Winston and PyPlot figures
    * Term and script chunks
    * Support for markdown, tex and rst output
