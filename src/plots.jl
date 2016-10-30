import Plots

"""Pre-execute hooks to set the plot size for the chunk """
function plots_set_size(chunk)
  w = chunk.options[:fig_width] * chunk.options[:dpi]
  h = chunk.options[:fig_height] * chunk.options[:dpi]
  Plots.default(size = (w,h))
  return chunk
end

push_preexecute_hook(plots_set_size)

function Base.display(report::Report, m::MIME"image/png", data::Plots.Plot)
    Plots.gui(data) #Required for savefig to work
    chunk = report.cur_chunk
    full_name, rel_name = get_figname(report, chunk)
    push!(report.figures, rel_name)
    Plots.savefig(data, full_name)
end

function Base.display(report::Report, m::MIME"application/pdf", data::Plots.Plot)
    Plots.gui(data)
    chunk = report.cur_chunk
    full_name, rel_name = get_figname(report, chunk)
    push!(report.figures, rel_name)
    Plots.savefig(data, full_name)
end
