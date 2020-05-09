import Mustache

abstract type WeaveChunk end

mutable struct WeaveDoc
    source::AbstractString
    basename::AbstractString
    path::AbstractString
    chunks::Array{WeaveChunk}
    cwd::AbstractString
    format::Any
    doctype::AbstractString
    header_script::String
    header::Dict
    template::Union{AbstractString,Mustache.MustacheTokens}
    css::AbstractString
    highlight_theme::Type{<:Highlights.AbstractTheme}
    fig_path::AbstractString
    chunk_defaults::Dict{Symbol,Any}
    function WeaveDoc(source, chunks, header)
        path, fname = splitdir(abspath(source))
        basename = splitext(fname)[1]
        new(
            source,
            basename,
            path,
            chunks,
            "",
            nothing,
            "",
            "",
            header,
            "",
            "",
            Highlights.Themes.DefaultTheme,
            "",
            deepcopy(rcParams[:chunk_defaults]),
        )
    end
end

struct ChunkOutput
    code::AbstractString
    stdout::AbstractString
    displayed::AbstractString
    rich_output::AbstractString
    figures::Array{AbstractString}
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
    figures::Array{AbstractString}
    result::Array{ChunkOutput}
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

abstract type Inline end

mutable struct DocChunk <: WeaveChunk
    content::Vector{Inline}
    number::Int
    start_line::Int
end

mutable struct InlineText <: Inline
    content::AbstractString
    si::Int
    ei::Int
    number::Int
end

mutable struct InlineCode <: Inline
    content::AbstractString
    si::Int
    ei::Int
    number::Int
    ctype::Symbol
    output::AbstractString
    rich_output::AbstractString
    figures::Array{AbstractString}
    function InlineCode(content, si, ei, number, ctype)
        new(content, si, ei, number, ctype, "", "", AbstractString[])
    end
end

struct TermResult end
struct ScriptResult end
struct CollectResult end
