
# Release notes for Weave.jl

### Changes in master

* Simple caching of code chunks
* Each document is executed in separate sandbox module instead of redefining the          same one. Fixes warnings and occasional segfaults.
* New chunk option: `line_width`.
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
