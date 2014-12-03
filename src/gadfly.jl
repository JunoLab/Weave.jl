using Gadfly

import Base: start, next, done, display, writemime


Gadfly.set_default_plot_format(:png)



function display(doc::Report, m::MIME"image/png", data)
    filename = @sprintf("%s_figure%d.png", doc.basename, doc.fignum)
    doc.fignum += 1
    out = open(filename, "w")
    writemime(out, m, data)
    close(out)

    push!(doc.figures, filename)
    push!(doc.executed, filename)
end
