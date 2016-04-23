import JSON, JLD

function write_cache(doc::WeaveDoc, cache_path)
    cache_dir = "$(doc.cwd)/$cache_path"
    isdir(cache_dir) || mkpath(cache_dir)
    name = "$cache_dir/$(doc.basename).json"
    JLD.save("$cache_dir/$(doc.basename).jld", Dict("doc" => doc))
    open(name, "w") do io
        write(io, JSON.json(doc))
    end
    return nothing
end

function read_cache(doc::WeaveDoc, cache_path)
    #name = "$(doc.cwd)/$cache_path/$(doc.basename).json"
    name = "$(doc.cwd)/$cache_path/$(doc.basename).jld"
    isfile(name) || return nothing
    #parsed = JSON.parsefile(name)
    return JLD.load(name)["doc"]
end

#read_cache returns a dictionary, parse to back to chunk
function restore_chunk(chunk::CodeChunk, cached)
    chunks = filter(x -> x.number == chunk.number &&
            string(typeof(x)) == "Weave.CodeChunk", cached.chunks)

    #Chunk types, don't match after loading. Need to reinitialize
    new_chunks = Any[]
    for c in chunks
      newc = CodeChunk(c.content, c.number, c.start_line, c.optionstring, c.options)
      newc.result_no = c.result_no
      newc.figures = c.figures
      newc.result = c.result
      push!(new_chunks, newc)
    end
    #options = Dict{Symbol, Any}()
    #info(cached["chunks"][idx])
    #for (keys,vals) = cached["chunks"][idx]["options"]
    #    options[symbol(keys)] = vals
    #end
    #haskey(options, :term_state) && (options[:term_state] = symbol(options[:term_state]))
    #chunk.options = options
    #chunk.content = cached["chunks"][idx]["content"]
    #chunk.output = cached["chunks"][idx]["output"]
    #chunk.figures = cached["chunks"][idx]["figures"]

    return new_chunks
end

#Could be used to restore inline code in future
function restore_chunk(chunk::DocChunk, cached)
      return chunk
end
