# [Chunk Options](@id chunk-options)

You can use chunk options to configure how each chunk is evaluated, rendered, etc.
Most of the ideas came from [chunk options in RMarkdown](http://yihui.name/knitr/options).


## Syntax

Chunk options come after [code chunk](@ref code-chunks) header.
There are two (slightly) different syntax to write them:
- (Julia's toplevel expression) options are separated by semicolon (`;`)
- (RMarkdown style) options are separated by comma (`,`)

Let's take a look at examples. All the following code chunk header are valid,
and so configured to hide the source code from generated output (`echo = false`)
and displays figures with 12cm width (`out_width = "12cm"`):
```md
 ```julia; echo = false; out_width = "12cm"

 ```{julia; echo = false; out_width = "12cm"}

 ```julia, echo = false, out_width = "12cm"

 ```{julia, echo = false, out_width = "12cm"}
```


## Weave Chunk Options

Weave currently supports the following chunk options:
we've mostly followed [RMarkdown's namings](http://yihui.name/knitr/options), but not all options are implemented.

### Evaluation

- `eval = true`: Evaluate the code chunk. If `false` the chunk won’t be executed.
- `cache = false`: Cache results, depending on `cache` parameter on [`weave`](@ref) function.
- `tangle = true`: Set tangle to `false` to exclude chunk from tangled code.

### Rendering

- `echo = true`: Echo the code in the output document. If `false` the source code will be hidden.
- `results = "markup"`: The output format of the printed results. `"markup"` for literal block, `"hidden"` for hidden results, or anything else for raw output (I tend to use `"tex"` for Latex and `"rst"` for rest). Raw output is useful if you want to e.g. create tables from code chunks.
- `term = false`: If `true` the output emulates a REPL session. Otherwise only stdout and figures will be included in output.
- `wrap = true`: Wrap long lines from output.
- `line_width = 75`: Line width for wrapped lines.
- `hold = false`: Hold all results until the end of the chunk.

### Figures

- `label = nothing`: Chunk label, will be used for figure labels in Latex as `fig:label`.
- `fig_width = 6`: Figure width passed to plotting library.
- `fig_height = 4`: Figure height passed to plotting library.
- `out_width`: Width of saved figure in output markup e.g. `"50%"`, `"12cm"`, `0.5\linewidth`
- `out_height`: Height of saved figure in output markup
- `dpi = 96`: Resolution of saved figures.
- `fig_cap`: Figure caption.
- `fig_ext`: File extension (format) of saved figures.
- `fig_pos = "!h"`: Figure position in Latex, e.g.: `"ht"`.
- `fig_env = "figure"`: Figure environment in Latex.


## Default Chunk Options

You can set the default chunk options (and `weave` arguments) for a document using `weave_options` key in YAML [Header Configuration](@ref).
E.g. to set the default `out_width` of all figures you can use:

```yaml
---
weave_options:
  out_width : 50%
---
```

You can also set or change the default chunk options for a document either before weave using the `set_chunk_defaults` function.

```@docs
set_chunk_defaults!
get_chunk_defaults
restore_chunk_defaults!
```
