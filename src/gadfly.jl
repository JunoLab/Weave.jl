using Gadfly

import Base: start, next, done, display, writemime


Gadfly.set_default_plot_format(:png)



function display(doc::Report, m::MIME"image/png", data)

    figpath = joinpath(report.cwd, report.figdir)
    isdir(figpath) || mkdir(figpath)

    ext = report.formatdict[:figfmt]



    fig = doc.fignum
    chunk = report.cur_chunk
    chunkid = (chunk[:name] == nothing) ? chunk[:number] : chunk[:name]
    full_name = joinpath(report.cwd, report.figdir, "$(report.basename)_$(chunkid)_$fig$ext")
    rel_name = "$(report.figdir)/$(report.basename)_$(chunkid)_$fig$ext" #Relative path is used in output

    docformat = formats[report.formatdict[:doctype]]

    if chunk[:term]
      chunk[:figure] = [rel_name]
      report.cur_result *= "\n" * report.formatdict[:codeend]
      report.cur_result *= formatfigures(chunk, docformat)
      report.cur_result *=  "\n\n" * report.formatdict[:codestart]
      chunk[:figure] = String[]
    else
      push!(doc.figures, rel_name)
    end

    doc.fignum += 1
    out = open(full_name, "w")
    writemime(out, m, data)
    close(out)


    #push!(doc.executed, filename)
end
