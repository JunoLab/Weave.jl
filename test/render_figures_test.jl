test_render_figures(format, chunk) = Weave.render_figures(get_format(format), chunk)


# Make a dummy codehunk with figure
chunk = Weave.CodeChunk("plot(x)", 1, 1, "", Dict())
options = merge(Weave.get_chunk_defaults(), chunk.options)
merge!(chunk.options, options)
chunk.figures = ["figs/figures_plot1.png"]


@test test_render_figures("md2tex", chunk) == "\\includegraphics{figs/figures_plot1.png}\n"
@test test_render_figures("texminted", chunk) == "\\includegraphics{figs/figures_plot1.png}\n"
@test test_render_figures("pandoc", chunk) == "![](figs/figures_plot1.png)\\ \n\n"
@test test_render_figures("github", chunk) == "![](figs/figures_plot1.png)\n"
@test test_render_figures("hugo", chunk) == "{{< figure src=\"../figs/figures_plot1.png\"  >}}"
@test test_render_figures("multimarkdown", chunk) == "![][figs/figures_plot1.png]\n\n[figs/figures_plot1.png]: figs/figures_plot1.png \n"
@test test_render_figures("md2html", chunk) == "<img src=\"figs/figures_plot1.png\"  />\n"


chunk.options[:out_width] = "100%"
@test test_render_figures("asciidoc", chunk) == "image::figs/figures_plot1.png[width=100%]\n"
@test test_render_figures("rst", chunk) == ".. image:: figs/figures_plot1.png\n   :width: 100%\n\n"


chunk.options[:fig_cap] = "Nice plot"
@test test_render_figures("pandoc", chunk) == "![Nice plot](figs/figures_plot1.png){width=100%}\n"
@test test_render_figures("md2tex", chunk) == "\\begin{figure}[!h]\n\\center\n\\includegraphics[width=1.0\\linewidth]{figs/figures_plot1.png}\n\\caption{Nice plot}\n\\end{figure}\n"
@test test_render_figures("md2html", chunk) == "<figure>\n<img src=\"figs/figures_plot1.png\" width=\"100%\" />\n<figcaption>Nice plot</figcaption>\n</figure>\n"
@test test_render_figures("rst", chunk) == ".. figure:: figs/figures_plot1.png\n   :width: 100%\n\n   Nice plot\n\n"
@test test_render_figures("multimarkdown", chunk) == "![Nice plot][figs/figures_plot1.png]\n\n[figs/figures_plot1.png]: figs/figures_plot1.png width=100%\n"
@test test_render_figures("asciidoc", chunk) == "image::figs/figures_plot1.png[width=100%,title=\"Nice plot\"]"


chunk.options[:label] = "somefig"
@test test_render_figures("pandoc", chunk) == "![Nice plot](figs/figures_plot1.png){width=100% #fig:somefig}\n"
