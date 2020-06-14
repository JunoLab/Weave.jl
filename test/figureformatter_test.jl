test_formatfigures(chunk, format) = Weave.formatfigures(chunk, get_format(format))


# Make a dummy codehunk with figure
chunk = Weave.CodeChunk("plot(x)", 1, 1, "", Dict())
options = merge(Weave.get_chunk_defaults(), chunk.options)
merge!(chunk.options, options)
chunk.figures = ["figs/figures_plot1.png"]


@test test_formatfigures(chunk, "md2tex") == "\\includegraphics{figs/figures_plot1.png}\n"
@test test_formatfigures(chunk, "texminted") == "\\includegraphics{figs/figures_plot1.png}\n"
@test test_formatfigures(chunk, "pandoc") == "![](figs/figures_plot1.png)\\ \n\n"
@test test_formatfigures(chunk, "github") == "![](figs/figures_plot1.png)\n"
@test test_formatfigures(chunk, "hugo") == "{{< figure src=\"../figs/figures_plot1.png\"  >}}"
@test test_formatfigures(chunk, "multimarkdown") == "![][figs/figures_plot1.png]\n\n[figs/figures_plot1.png]: figs/figures_plot1.png \n"
@test test_formatfigures(chunk, "md2html") == "<img src=\"figs/figures_plot1.png\"  />\n"


chunk.options[:out_width] = "100%"
@test test_formatfigures(chunk, "asciidoc") == "image::figs/figures_plot1.png[width=100%]\n"
@test test_formatfigures(chunk, "rst") == ".. image:: figs/figures_plot1.png\n   :width: 100%\n\n"


chunk.options[:fig_cap] = "Nice plot"
@test test_formatfigures(chunk, "pandoc") == "![Nice plot](figs/figures_plot1.png){width=100%}\n"
@test test_formatfigures(chunk, "md2tex") == "\\begin{figure}[!h]\n\\center\n\\includegraphics[width=1.0\\linewidth]{figs/figures_plot1.png}\n\\caption{Nice plot}\n\\end{figure}\n"
@test test_formatfigures(chunk, "md2html") == "<figure>\n<img src=\"figs/figures_plot1.png\" width=\"100%\" />\n<figcaption>Nice plot</figcaption>\n</figure>\n"
@test test_formatfigures(chunk, "rst") == ".. figure:: figs/figures_plot1.png\n   :width: 100%\n\n   Nice plot\n\n"
@test test_formatfigures(chunk, "multimarkdown") == "![Nice plot][figs/figures_plot1.png]\n\n[figs/figures_plot1.png]: figs/figures_plot1.png width=100%\n"
@test test_formatfigures(chunk, "asciidoc") == "image::figs/figures_plot1.png[width=100%,title=\"Nice plot\"]"


chunk.options[:label] = "somefig"
@test test_formatfigures(chunk, "pandoc") == "![Nice plot](figs/figures_plot1.png){width=100% #fig:somefig}\n"
