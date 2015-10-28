
type WeaveDoc
    source::AbstractString
    basename::AbstractString
    path::AbstractString
    chunks::Array
    cwd::AbstractString
    format
    doctype::AbstractString
    function WeaveDoc(source, chunks)
        path, fname = splitdir(abspath(source))
        basename = splitext(fname)[1]
        new(source, basename, path, chunks, "", nothing, "")
    end
end


type CodeChunk
    content::AbstractString
    number::Int
    start_line::Int
    option_string::AbstractString
    options::Dict{Symbol, Any}
    output::AbstractString
    figures::Array{AbstractString}
    function CodeChunk(content, number, start_line, option_string, options)
        new(content, number, start_line, option_string, options, "", AbstractString[])
    end
end

type DocChunk
    content::AbstractString
    number::Int
    start_line::Int
end
