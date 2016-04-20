
# Release notes for Weave.jl

### In master

* Change pandoc output to use inline images if there is no caption.
* Use Documenter.jl for documentation.
* Add chunk option `hold`, replaces results = "hold". This way you can use e.g. `hold = true, results=raw`.
* Methods for setting and restoring default chunk options for documents.
* New output options `md2pdf` and `md2html`, both use pandoc to output pdf
  and html files directly with own templates.
* Restored and improved Winston support.

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
