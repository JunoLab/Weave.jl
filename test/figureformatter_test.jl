using Weave

# Make a dummy codehunk with figure
chunk = Weave.CodeChunk("plot(x)", 1, 1, "", Dict())
options = merge(Weave.rcParams[:chunk_defaults], chunk.options)
merge!(chunk.options, options)
chunk.figures = ["figs/figures_plot1.png"]


@test Weave.formatfigures(chunk, Weave.md2tex) == "\\includegraphics{figs/figures_plot1.png}\n"
@test Weave.formatfigures(chunk, Weave.tex) == "\\includegraphics[]{figs/figures_plot1.png}\n"
@test Weave.formatfigures(chunk, Weave.texminted) == "\\includegraphics[]{figs/figures_plot1.png}\n"
@test Weave.formatfigures(chunk, Weave.pandoc) == "![](figs/figures_plot1.png)\\ \n\n"
@test Weave.formatfigures(chunk, Weave.github) == "![](figs/figures_plot1.png)\n"
@test Weave.formatfigures(chunk, Weave.hugo) == "{{< figure src=\"../figs/figures_plot1.png\"  >}}"
@test Weave.formatfigures(chunk, Weave.multimarkdown) == "![][figs/figures_plot1.png]\n\n[figs/figures_plot1.png]: figs/figures_plot1.png \n"
@test Weave.formatfigures(chunk, Weave.md2html) == "<img src=\"figs/figures_plot1.png\"  />\n"




