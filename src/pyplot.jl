using PyPlot

function savefigs_pyplot(chunk, report::Report)
    fignames = AbstractString[]
    ext = report.formatdict[:fig_ext]
    figpath = joinpath(report.cwd, chunk.options[:fig_path])
    isdir(figpath) || mkdir(figpath)
    chunkid = (chunk.options[:name] == nothing) ? chunk.number : chunk.options[:name]
    #Iterate over all open figures, save them and store names
    for fig = plt.get_fignums()
        full_name, rel_name = get_figname(report, chunk, fignum=fig)
        savefig(full_name, dpi=chunk.options[:dpi])
        push!(fignames, rel_name)
        plt.draw()
        plt.close()
    end
    return fignames
end
