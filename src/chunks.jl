
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
