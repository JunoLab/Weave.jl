import Plots

"""Pre-execute hooks to set the plot size for the chunk """
function plots_set_size(chunk)
  w = chunk.options[:fig_width] * chunk.options[:dpi]
  h = chunk.options[:fig_height] * chunk.options[:dpi]
  Plots.default(size = (w,h))
  return chunk
end

push_preexecute_hook(plots_set_size)

#PNG or SVG is not working, output html
function Base.display(report::Report, m::MIME"image/svg+xml", data::Plots.Plot{Plots.PlotlyBackend})#
  #Remove extra spaces from start of line for pandoc
  s = reprmime(MIME("text/html"), data)
  splitted = split(s, "\n")
  start = split(splitted[1], r"(?=<div)")
  #script = lstrip(start[1]) #local

  div = lstrip(start[2])
  plot = join(map(lstrip, splitted[2:end]), "\n")

  if report.first_plot
    report.header_script *= "<script src=\"https://cdn.plot.ly/plotly-latest.min.js\"></script>"
    report.first_plot = false
  end

    report.rich_output *= "\n" * div * "\n" * plot
end

function Base.display(report::Report, m::MIME"image/png", data::Plots.Plot{Plots.PlotlyBackend})#
  display(report, MIME("image/svg+xml"), data)
end


#PNG or SVG is not working, output html
function Base.display(report::Report, m::MIME"image/svg+xml", plot::Plots.Plot{Plots.PlotlyJSBackend})
  body = Plots.PlotlyJS.html_body(plot.o.plot)

  if report.first_plot
    report.header_script *= "<script src=\"https://cdn.plot.ly/plotly-latest.min.js\"></script>"
    report.first_plot = false
  end

  report.rich_output *= "\n" * body
end

function Base.display(report::Report, m::MIME"image/png", plot::Plots.Plot{Plots.PlotlyJSBackend})
  display(report, MIME("image/svg+xml"), data)
end


"""Add saved figure name to results and return the name"""
function add_pyplot_figure(report::Report, plot::Plots.Plot{Plots.PyPlotBackend}, ext)
  chunk = report.cur_chunk
  full_name, rel_name = get_figname(report, chunk, ext = ext)

  Plots.savefig(plot, full_name)
  push!(report.figures, rel_name)
  report.fignum += 1
  return full_name
end

function Base.display(report::Report, m::MIME"application/pdf", plot::Plots.Plot{Plots.PyPlotBackend})
    add_pyplot_figure(report, plot, ".pdf")
end

function Base.display(report::Report, m::MIME"image/png", plot::Plots.Plot{Plots.PyPlotBackend})
    add_pyplot_figure(report, plot, ".png")
end

function Base.display(report::Report, m::MIME"image/svg+xml", plot::Plots.Plot{Plots.PyPlotBackend})
    add_pyplot_figure(report, plot, ".svg")
end
