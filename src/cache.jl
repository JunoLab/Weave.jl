import JLD

function write_cache(doc::WeaveDoc, cache_path)
    cache_dir = joinpath(doc.cwd, cache_path)
    isdir(cache_dir) || mkpath(cache_dir)
    JLD.save(joinpath(cache_dir, doc.basename * ".jld"), Dict("doc" => doc))
    return nothing
end

function read_cache(doc::WeaveDoc, cache_path)
    name = joinpath(doc.cwd, cache_path, doc.basename * ".jld")
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
      newc.rich_output = c.rich_output
      push!(new_chunks, newc)
    end
    return new_chunks
end

#Restore inline code
function restore_chunk(chunk::DocChunk, cached::WeaveDoc)
    #Get chunk from cached doc
    c_chunk = filter(x -> x.number == chunk.number && 
                    isa(x,  DocChunk), cached.chunks)
    isempty(c_chunk) && return chunk
    c_chunk = c_chunk[1]

    #Collect cached code
    c_inline = filter(x -> isa(x, InlineCode), c_chunk.content)
    isempty(c_inline) && return chunk

    #Restore cached results for Inline code
    n = length(chunk.content)    
    for i in 1:n
        if isa(chunk.content[i], InlineCode)
            ci = filter(x -> x.number == chunk.content[i].number, c_inline)
            isempty(ci) && continue
            chunk.content[i].output = ci[1].output
            chunk.content[i].rich_output = ci[1].rich_output
            chunk.content[i].figures = ci[1].figures
        end
    end
    return chunk
end
