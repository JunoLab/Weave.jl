import JSON


function write_cache(doc::WeaveDoc, cache_path)
    cache_dir = "$(doc.cwd)/$cache_path"
    isdir(cache_dir) || mkpath(cache_dir)
    name = "$cache_dir/$(doc.basename).json"
    open(name, "w") do io
        write(io, JSON.json(doc))
    end
    return nothing
end

function read_cache(doc::WeaveDoc, cache_path)
    name = "$(doc.cwd)/$cache_path/$(doc.basename).json"
    isfile(name) || return nothing
    parsed = JSON.parsefile(name)
end

#read_cache returns a dictionary, parse to back to chunk
function restore_chunk(chunk::CodeChunk, cached, idx)
    options = Dict{Symbol, Any}()
    for (keys,vals) = cached["chunks"][idx]["options"]
        options[symbol(keys)] = vals
    end
    haskey(options, :term_state) && (options[:term_state] = symbol(options[:term_state]))

    chunk.options = options
    chunk.content = cached["chunks"][idx]["content"]
    chunk.output = cached["chunks"][idx]["output"]
    chunk.figures = cached["chunks"][idx]["figures"]

    return chunk
end

function restore_chunk(chunk::DocChunk, cached, idx)
    chunk
end
