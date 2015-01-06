
type WeaveDoc
    source::String
    basename::String
    path::String
    chunks::Array
    cwd::String
    format
    function WeaveDoc(source, chunks)
        path, fname = splitdir(abspath(source))
        basename = splitext(fname)[1]
        new(source, basename, path, chunks, "", nothing)
    end
end


type CodeChunk
    content::String
    number::Int
    start_line::Int
    option_string::String
    options::Dict{Symbol, Any}
    output::String
    figures::Array{String}
    function CodeChunk(content, number, start_line, option_string, options)
        new(content, number, start_line, option_string, options, "", String[])
    end
end

type DocChunk
    content::String
    number::Int
    start_line::Int
end
