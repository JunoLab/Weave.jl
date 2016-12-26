
abstract WeaveChunk
abstract Inline

type WeaveDoc
    source::AbstractString
    basename::AbstractString
    path::AbstractString
    chunks::Array{WeaveChunk}
    cwd::AbstractString
    format
    doctype::AbstractString
    header_script::String
    header::Dict
    template::AbstractString
    css::AbstractString
    highlight_theme
    fig_path::AbstractString
    function WeaveDoc(source, chunks, header)
        path, fname = splitdir(abspath(source))
        basename = splitext(fname)[1]
        new(source, basename, path, chunks, "", nothing, "", "", header,
          "", "", Highlights.Themes.DefaultTheme, "")
    end
end

immutable ChunkOutput
    code::AbstractString
    stdout::AbstractString
    displayed::AbstractString
    rich_output::AbstractString
    figures::Array{AbstractString}
end

type CodeChunk <: WeaveChunk
    content::AbstractString
    number::Int
    result_no::Int
    start_line::Int
    optionstring::AbstractString
    options::Dict{Symbol, Any}
    output::AbstractString
    rich_output::AbstractString
    figures::Array{AbstractString}
    result::Array{ChunkOutput}
    function CodeChunk(content, number, start_line, optionstring, options)
        new(rstrip(content), number, 0, start_line, optionstring, options, "","", AbstractString[], ChunkOutput[])
    end
end

type DocChunk <: WeaveChunk
    content::Array{Inline}
    number::Int
    start_line::Int
    function DocChunk(text::AbstractString, number::Int, start_line::Int, inline_regex = nothing)
        chunks = parse_inline(text, inline_regex)
        new(chunks, number, start_line)
    end
end

type InlineText <: Inline
    content::AbstractString
    si::Int64
    ei::Int64
end

type InlineCode <: Inline
    content::AbstractString
    si::Int64
    ei::Int64
    output::AbstractString
    rich_output::AbstractString
    figures::Array{AbstractString}
    function InlineCode(content, si, ei)
        new(content, si, ei, "", "", AbstractString[])
    end
end

type TermResult
end

type ScriptResult
end

type CollectResult
end
