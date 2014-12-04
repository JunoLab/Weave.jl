using Gadfly

Gadfly.set_default_plot_format(:png)

#Captures figures
function Base.display(report::Report, m::MIME"image/png", p::Plot)
    chunk = report.cur_chunk

    if chunk[:fig_ext] != ".png"
      chunk[:fig_ext]
      warn("Saving figures as .png with Gadfly")
    end

    full_name, rel_name = get_figname(report, chunk)

    docformat = formats[report.formatdict[:doctype]]

    #Add to results for term chunks and store otherwise
    if chunk[:term]
      chunk[:figure] = [rel_name]
      report.cur_result *= "\n" * report.formatdict[:codeend]
      report.cur_result *= formatfigures(chunk, docformat)
      report.cur_result *=  "\n\n" * report.formatdict[:codestart]
      chunk[:figure] = String[]
    else
      push!(report.figures, rel_name)
    end

    report.fignum += 1

    #TODO other formats
    r = chunk[:dpi]/96 #Relative to Gadfly default 96dpi
    draw(PNG(full_name, chunk[:fig_width]inch*r, chunk[:fig_height]inch*r ), p)
    #out = open(full_name, "w")
    #writemime(out, m, data)
    #close(out)
end
