import HDF5, JLD

function write_cache(doc::WeaveDoc, cache_path)
    isdir(cache_path) || mkdir(cache_path)
    name = "$cache_path/$(doc.basename).jld"
    JLD.save(name, "doc", doc)
    #open(name, "w") do io
    #    write(io, JSON.json(doc))
    #end
    return nothing
end

function read_cache(doc::WeaveDoc, cache_path)
    name = "$cache_path/$(doc.basename).jld"
    isfile(name) || return nothing
    return JLD.load(name, "doc")
    #parsed = JSON.parsefile(name)
    #doc = WeaveDoc(parsed["source"], parsed["chunks"],
    #parsed["cwd"], parsed["doctype"])
end



#Todo caching of data, can get the contents of module using:
#names(ReportSandBox, all=true)
