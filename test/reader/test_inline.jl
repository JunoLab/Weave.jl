# TODO: test evaluation

using Weave.Mustache
using Weave: parse_inlines, InlineText, InlineCode


@testset "`parse_inlines` basic" begin

@test filter(parse_inlines("text")) do chunk
    chunk isa InlineCode
end |> isempty

@test filter(parse_inlines("text")) do chunk
    chunk isa InlineText &&
    chunk.content == "text"
end |> length === 1

@test filter(parse_inlines("`j code`")) do chunk
    chunk isa InlineCode &&
    chunk.ctype === :inline &&
    chunk.content == "code"
end |> length == 1

@test filter(parse_inlines("! code")) do chunk
    chunk isa InlineCode &&
    chunk.ctype === :line &&
    chunk.content == "code"
end |> length == 1

@test filter(parse_inlines("text ! maybe_intended_to_be_code")) do chunk # invalid inline chunk
    chunk isa InlineText &&
    chunk.content == "maybe_intended_to_be_code"
end |> isempty

end


@testset "`parse_inlines` multiple lines" begin

str = """
- item1
- `j code`
- item2
"""
chunks = parse_inlines(str)

let chunk = chunks[1]
    @test chunk isa InlineText
    @test occursin("- item1", chunk.content)
end

let chunk = chunks[2]
    @test chunk isa InlineCode
    @test occursin("code", chunk.content)
end

let chunk = chunks[3]
    @test chunk isa InlineText
    @test occursin("- item2", chunk.content)
end

end


@testset "`parse_inlines` unicode handling" begin

str = """
- eng1 `j :eng1`
- eng2`j :eng2`
- 日本語1 `j :日本語1`
- 日本語2`j :日本語2`
"""
chunks = parse_inlines(str)

@test filter(chunks) do chunk
    chunk isa InlineCode &&
    chunk.number === 1 &&
    chunk.content == ":eng1"
end |> length === 1

@test filter(chunks) do chunk
    chunk isa InlineCode &&
    chunk.number === 2 &&
    chunk.content == ":eng2"
end |> length === 1

@test filter(chunks) do chunk
    chunk isa InlineCode &&
    chunk.number === 3 &&
    chunk.content == ":日本語1"
end |> length === 1

@test filter(chunks) do chunk
    chunk isa InlineCode &&
    chunk.number === 4 &&
    chunk.content == ":日本語2"
end |> length === 1

end
