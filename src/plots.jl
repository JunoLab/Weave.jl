import Plots

"""Pre-execute hooks to set the plot size for the chunk """
function plots_set_size(chunk)
  w = chunk.options[:fig_width] * chunk.options[:dpi]
  h = chunk.options[:fig_height] * chunk.options[:dpi]
  Plots.default(size = (w,h))
  return chunk
end

push_preexecute_hook(plots_set_size)
