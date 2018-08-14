using Weave
using Test

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

chunk.options[:out_width] = "100%"
@test Weave.formatfigures(chunk, Weave.adoc) == "image::figs/figures_plot1.png[width=100%]\n"
@test Weave.formatfigures(chunk, Weave.rst) == ".. image:: figs/figures_plot1.png\n   :width: 100%\n\n"

chunk.options[:fig_cap] = "Nice plot"
@test Weave.formatfigures(chunk, Weave.tex) == "\\begin{figure}[!h]\n\\center\n\\includegraphics[width=100%]{figs/figures_plot1.png}\n\\caption{Nice plot}\n\\end{figure}\n"
@test Weave.formatfigures(chunk, Weave.pandoc) == "![Nice plot](figs/figures_plot1.png){width=100%}\n"
@test Weave.formatfigures(chunk, Weave.md2tex) == "\\begin{figure}[!h]\n\\center\n\\includegraphics[width=100%]{figs/figures_plot1.png}\n\\caption{Nice plot}\n\\end{figure}\n"
@test Weave.formatfigures(chunk, Weave.md2html) == "<figure>\n<img src=\"figs/figures_plot1.png\" width=\"100%\" />\n<figcaption>Nice plot</figcaption>\n</figure>\n"
@test Weave.formatfigures(chunk, Weave.rst) == ".. figure:: figs/figures_plot1.png\n   :width: 100%\n\n   Nice plot\n\n"
@test Weave.formatfigures(chunk, Weave.multimarkdown) == "![Nice plot][figs/figures_plot1.png]\n\n[figs/figures_plot1.png]: figs/figures_plot1.png width=100%\n"
@test Weave.formatfigures(chunk, Weave.adoc) == "image::figs/figures_plot1.png[width=100%,title=\"Nice plot\"]"

chunk.options[:label] = "somefig"
@test Weave.formatfigures(chunk, Weave.pandoc) == "![Nice plot](figs/figures_plot1.png){width=100% #fig:somefig}\n"
@test Weave.formatfigures(chunk, Weave.tex) == "\\begin{figure}[!h]\n\\center\n\\includegraphics[width=100%]{figs/figures_plot1.png}\n\\caption{Nice plot}\n\\label{fig:somefig}\n\\end{figure}\n"
@test Weave.formatfigures(chunk, Weave.tex) == Weave.formatfigures(chunk, Weave.md2tex)
