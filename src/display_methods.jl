
"""Add saved figure name to results and return the name"""
function add_figure(report::Report, ext)
  chunk = report.cur_chunk
  full_name, rel_name = get_figname(report, chunk, ext = ext)
  push!(report.figures, rel_name)
  report.fignum += 1
  return full_name
end

function Base.display(report::Report, m::MIME"image/png", data)
    figname = add_figure(report, ".png")
    open(figname, "w") do io
      writemime(io, m, data)
    end
end

function Base.display(report::Report, m::MIME"image/svg+xml", data)
    figname = add_figure(report, ".svg")
    open(figname, "w") do io
      writemime(io, m, data)
    end
end

function Base.display(report::Report, m::MIME"application/pdf", data)
    figname = add_figure(report, ".pdf")
    open(figname, "w") do io
      writemime(io, m, data)
    end
end

#Text is written to stdout
function Base.display(report::Report, m::MIME"text/plain", data)
    s = reprmime(m, data)
    print("\n" * s)
end

#Catch to rich_output
function Base.display(report::Report, m::MIME"text/html", data)
    s = reprmime(m, data)
    report.cur_chunk.rich_output *= "\n" * s
end
