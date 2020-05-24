# TODO: concreate typing

abstract type WeaveChunk end
abstract type Inline end

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
    content::AbstractString
    number::Int
    result_no::Int
    start_line::Int
    optionstring::AbstractString
    options::Dict{Symbol,Any}
    output::AbstractString
    rich_output::AbstractString
    figures::Vector{AbstractString}
    result::Vector{ChunkOutput}
    function CodeChunk(content, number, start_line, optionstring, options)
        new(
            rstrip(content) * "\n",
            number,
            0,
            start_line,
            optionstring,
            options,
            "",
            "",
            AbstractString[],
            ChunkOutput[],
        )
    end
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

struct TermResult end
struct ScriptResult end
struct CollectResult end
