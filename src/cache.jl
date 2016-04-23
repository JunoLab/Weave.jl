import JLD

function write_cache(doc::WeaveDoc, cache_path)
    cache_dir = "$(doc.cwd)/$cache_path"
    isdir(cache_dir) || mkpath(cache_dir)
    JLD.save("$cache_dir/$(doc.basename).jld", Dict("doc" => doc))
    return nothing
end

function read_cache(doc::WeaveDoc, cache_path)
    name = "$(doc.cwd)/$cache_path/$(doc.basename).jld"
    isfile(name) || return nothing
    return JLD.load(name)["doc"]
end


function restore_chunk(chunk::CodeChunk, cached)
    chunks = filter(x -> x.number == chunk.number &&
            string(typeof(x)) == "Weave.CodeChunk", cached.chunks)

    #Chunk types, don't match after loading. Fix by constructing chunks
    #from loaded content
    new_chunks = Any[]
    for c in chunks
      newc = CodeChunk(c.content, c.number, c.start_line, c.optionstring, c.options)
      newc.result_no = c.result_no
      newc.figures = c.figures
      newc.result = c.result
      newc.output = c.output
      push!(new_chunks, newc)
    end
    return new_chunks
end

#Could be used to restore inline code in future
function restore_chunk(chunk::DocChunk, cached)
      return chunk
end
