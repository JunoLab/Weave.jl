module WeavePlots
import Plots
import Weave

"""Pre-execute hooks to set the plot size for the chunk """
function plots_set_size(chunk)
  w = chunk.options[:fig_width] * chunk.options[:dpi]
  h = chunk.options[:fig_height] * chunk.options[:dpi]
  Plots.default(size = (w,h))
  return chunk
end

Weave.push_preexecute_hook(plots_set_size)

#PNG or SVG is not working, output html
function Base.display(report::Weave.Report, m::MIME"image/svg+xml", data::Plots.Plot{Plots.PlotlyBackend})#
  #Remove extra spaces from start of line for pandoc
  s = repr(MIME("text/html"), data)
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

function Base.display(report::Weave.Report, m::MIME"image/png", data::Plots.Plot{Plots.PlotlyBackend})#
  display(report, MIME("image/svg+xml"), data)
end


#PNG or SVG is not working, output html
function Base.display(report::Weave.Report, m::MIME"image/svg+xml", plot::Plots.Plot{Plots.PlotlyJSBackend})
  body = Plots.PlotlyJS.html_body(plot.o.plot)

  if report.first_plot
    report.header_script *= "<script src=\"https://cdn.plot.ly/plotly-latest.min.js\"></script>"
    report.first_plot = false
  end

  report.rich_output *= "\n" * body
end

function Base.display(report::Weave.Report, m::MIME"image/png", plot::Plots.Plot{Plots.PlotlyJSBackend})
  display(report, MIME("image/svg+xml"), data)
end


"""Add saved figure name to results and return the name"""
function add_plots_figure(report::Weave.Report, plot::Plots.Plot, ext)
  chunk = report.cur_chunk
  full_name, rel_name = Weave.get_figname(report, chunk, ext = ext)

  Plots.savefig(plot, full_name)
  push!(report.figures, rel_name)
  report.fignum += 1
  return full_name
end

function Base.display(report::Weave.Report, m::MIME"application/pdf", plot::Plots.Plot)
    add_plots_figure(report, plot, ".pdf")
end

function Base.display(report::Weave.Report, m::MIME"image/png", plot::Plots.Plot)
    add_plots_figure(report, plot, ".png")
end

function Base.display(report::Weave.Report, m::MIME"image/svg+xml", plot::Plots.Plot)
    add_plots_figure(report, plot, ".svg")
end

# write out html to view Animated gif
function Base.display(report::Weave.Report, ::MIME"text/html", agif::Plots.AnimatedGif)
  ext = agif.filename[end-2:end]
  res = ""
  if ext == "gif"
      img = stringmime(MIME("image/gif"), read(agif.filename))
      res = "<img src=\"data:image/gif;base64,$img\" />"
  elseif ext in ("mov", "mp4")
      #Uncomment to embed mp4, make global or chunk option?
      #img = stringmime(MIME("video/$ext"), read(agif.filename))
      #res = "<video controls><source src=\"data:video/$(ext);base64,$img\" type=\"video/$ext\"></video>"
      res = "<video controls><source src=\"$(relpath(agif.filename))\" type=\"video/$ext\"></video>"
  else
      error("Cannot show animation with extension $ext: $agif")
  end

  report.rich_output *= "\n" * res * "\n"
end

end
