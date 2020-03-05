# Chunk options

I've mostly followed [Knitr](http://yihui.name/knitr/options)'s naming for chunk options, but not all options are implemented.

Options are separated using ";" and need to be valid Julia expressions. Example: markdown code chunk that saves and displays a 12 cm wide image and hides the source code:

`julia; out_width="12cm"; echo=false`

Weave currently supports the following chunk options with the following defaults:

## Options for code

* `echo = true`. Echo the code in the output document. If `false` the source code will be hidden.
* `results = "markup"`. The output format of the printed results. "markup" for literal block, "hidden" for hidden results or anything else for raw output (I tend to use ‘tex’ for Latex and ‘rst’ for rest. Raw output is useful if you wan’t to e.g. create tables from code chunks.
* `eval = true`. Evaluate the code chunk. If false the chunk won’t be executed.
* `term=false`. If true the output emulates a REPL session. Otherwise only stdout and figures will be included in output.
* `label`. Chunk label, will be used for figure labels in Latex as fig:label
* `wrap = true`. Wrap long lines from output.
* `line_width = 75`. Line width for wrapped lines.
* `cache = false`. Cache results, depends on `cache` parameter on `weave` function.
* `hold = false`. Hold all results until the end of the chunk.
* `tangle = true`. Set tangle to false to exclude chunk from tangled code.

## Options for figures

* `fig_width`. Figure width passed to plotting library e.g. `800`
* `fig_height` Figure height passed to plotting library
* `out_width`. Width of saved figure in output markup e.g. "50%", "12cm", `0.5\linewidth`
* `out_height`. Height of saved figure in output markup
* `dpi`=96. Resolution of saved figures.
* `fig_cap`. Figure caption.
* `label`. Chunk label, will be used for figure labels in Latex as fig:label
* `fig_ext`. File extension (format) of saved figures.
* `fig_pos="!h"`. Figure position in Latex.
* `fig_env="figure"`. Figure environment in Latex.


## Set default chunk options

You can set the default chunk options (and `weave` arguments) for a document using the YAML header `options` field. e.g to set the default `out_width` of all figures you can use:

```yaml
---
options:
      out_width : 50%
---
```

You can also set or change the default chunk options for a document either before weave using the `set_chunk_defaults function`.

```@docs
set_chunk_defaults(opts)
get_chunk_defaults()
restore_chunk_defaults()
```
