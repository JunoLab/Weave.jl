# TODO: concreate typing

abstract type WeaveChunk end
abstract type Inline end
abstract type WeaveFormat end

mutable struct WeaveDoc
    source::AbstractString
    basename::AbstractString
    path::AbstractString
    chunks::Vector{WeaveChunk}
    cwd::AbstractString
    format::Any
    doctype::String
    header_script::String
    header::Dict
    chunk_defaults::Dict{Symbol,Any}
end

struct ChunkOutput
    code::AbstractString
    stdout::AbstractString
    displayed::AbstractString
    rich_output::AbstractString
    figures::Vector{AbstractString}
end

mutable struct CodeChunk <: WeaveChunk
    content::String
    number::Int
    start_line::Int
    optionstring::String
    options::Dict{Symbol,Any}
    output::AbstractString
    rich_output::AbstractString
    figures::Vector{String}
    result::Vector{ChunkOutput}
end

function CodeChunk(content, number, start_line, optionstring, options)
    return CodeChunk(
        string(rstrip(content), '\n'), # normalize end of chunk)
        number,
        start_line,
        optionstring,
        options,
        "",
        "",
        AbstractString[],
        ChunkOutput[]
    )
end

mutable struct DocChunk <: WeaveChunk
    content::Vector{Inline}
    number::Int
    start_line::Int
end

struct InlineText <: Inline
    content::String
    number::Int
end

mutable struct InlineCode <: Inline
    content::String
    number::Int
    ctype::Symbol
    output::String
    rich_output::String
    figures::Vector{String}
end
InlineCode(content, number, ctype) = InlineCode(content, number, ctype, "", "", String[])
