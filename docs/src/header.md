# Header Configuration

When `weave`ing a markdown document, you use YAML header to provide additional metadata and configuration options.
A YAML header should be in the beginning of the input document delimited with `---`.


!!! warning
    YAML header configuration is only supported when `weave`ing [markdown or Noweb syntax documents](@ref document-syntax).


## Document Metadata

You can set additional document metadata in YAML header.
When `weave`ing to Julia markdown documents to HTML or PDF, Weave respects the following metadata specification:
- `title`
- `author`
- `date`

An example:
```yaml
---
title : Header Example
author : Shuhei Kadowaki
date: 16th May 2020
---
```

!!! note
    You can also have other metadata, but they won't appear in the resulting HTML and PDF.
    If you weave to Julia markdown to GitHub/Hugo markdown, all the metadata will be preserved.

### Dynamic Metadata

The metadata can be given "dynamically"; if you have [inline code](@ref) within YAML header, they will be evaluated _after_ evaluating all the chunks and replaced with the results.

The example document below will set `date` metadata dynamically.
Note that `Date` is available since the chunk is evaluated first.
```md
 ---
 title : Header Example
 author : Shuhei Kadowaki
 date: `j Date(now())`
 ---

 ```julia; echo = false
 using Datas
 ```
```


## Configuration Options

Each of keyword arguments of [`weave`](@ref) can be set in the YAML header under `options` field.
You can also set [Chunks Options](@ref) there that will be applied globally.

The example below sets `out_path` and `doctype` options and overwrites `term` and `wrap` chunk options:
```yaml
---
title : Header Example
author : Shuhei Kadowaki
date: 16th May 2020
weave_options:
  out_path: relative/path/to/this/document
  doctype: github
  term: true
  wrap: false
---
```

!!! note
    - configurations specified within the YAML header have higher precedence than those specified via `weave` keyword arguments
    - chunk options specified within each chunk have higher precedence than the global global chunk options specified within the YAML header

!!! warning
    As opposed to metadata, _most_ of those configuration options can't be given dynamically (i.e. can't be via inline code),
    since they are needed for evaluation of chunks themselves.
    But some configuration options that are needed "formatting" document can still be given dynamically:
    - `template`
    - `css`
    - `highlight_theme`
    - `pandoc_options`
    - `latex_cmd`
    - `keep_unicode`

    See also: [`weave`](@ref)


## Format Specific Options

The header configurations can be format specific.
Here is how to set different `out_path` for `md2html` and `md2pdf` and set `fig_ext` globally:
```yaml
---
weave_options:
  md2html:
    out_path : html
  md2pdf:
    out_path : pdf
  fig_ext : .png
---
```
