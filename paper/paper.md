---
title: 'Weave.jl: Scientific Reports Using Julia'
tags:
  - Scientific reports
  - Julia
authors:
 - name: Matti Pastell
   orcid: 0000-0002-5810-4801
   affiliation: 1
affiliations:
 - name: Natural Resources Institute Finland (Luke)
   index: 1
date: 6 March 2017
bibliography: paper.bib
---

# Summary

Weave is a tool for writing scientific reports using Julia
[@julia]. It allows writing of text, mathematics and code in a single
document which can be run capturing results into a rich report.
Output can include text using several markup languages, plots
generated using one of the several Julia plotting libraries and other
objects displayed using Julia's multimedia output. The workflow is
very similar to using Knitr [@knitr] R-package.

Weave supports noweb, markdown, script syntax for delimiting code from
text in the source document and several output formats including
Markdown and Latex. The output from code can be controlled using chunk
options making it possible e.g. to hide code and only show output when
needed as well as set a figure caption and figure size. The library
also has methods for converting documents from all input formats to
Jupyter notebooks and vice versa.

The package aims to support writing scientific papers and enable easy
sharing of analysis in order to promote reproducible research. It also
aims to enable simple writing of educational material, tutorials and
blog posts.

# References
