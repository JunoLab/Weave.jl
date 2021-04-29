using Weave: parse_options, parse_markdown


@testset "`parse_options`" begin

# general
@test isempty(parse_options(""))
@test (:opt => nothing) in parse_options("opt = nothing")

# Weave style -- semicolon separated
let opts = parse_options("opt1 = 1; opt2 = \"2\"")
    @test (:opt1 => 1) in opts
    @test (:opt2 => "2") in opts
end
# robust parsing
@test let opts = parse_options("invalid; valid = nothing")
    @test (:valid => nothing) in opts
    true
end

# RMarkdown style -- comma separated
let opts = parse_options("opt1 = 1, opt2 = \"2\"")
    @test (:opt1 => 1) in opts
    @test (:opt2 => "2") in opts
end
# robust parsing
@test let opts = parse_options("invalid, valid = nothing")
    @test (:valid => nothing) in opts
    true
end

end


@testset "`parse_markdown` Julia markdown format" begin

get_options(str) =
    (chunk = first(last(parse_markdown(str))); @test hasproperty(chunk, :options); chunk.options)

# Julia markdown
@test get_options("```julia\n```") |> length === 1
@test get_options("```julia \n```") |> length === 1
@test get_options("```{julia}\n```") |> length === 1
@test get_options("```{julia }\n```") |> length === 1

# Weave style -- semicolon separated
@test get_options("```julia;\n```") |> length === 1
@test get_options("```julia ;\n```") |> length === 1
@test get_options("```julia; \n```") |> length === 1
@test (:opt => nothing) in get_options("```julia; opt = nothing\n```")
@test (:opt => nothing) in get_options("```{julia; opt = nothing}\n```")
let opts = get_options("```julia; opt1 = 1; opt2 = \"2\"\n```")
    @test (:opt1 => 1) in opts
    @test (:opt2 => "2") in opts
end
let opts = get_options("```{julia; opt1 = 1; opt2 = \"2\"}\n```")
    @test (:opt1 => 1) in opts
    @test (:opt2 => "2") in opts
end

# RMarkdown style -- comma separated
@test get_options("```julia,\n```") |> length === 1
@test get_options("```julia ,\n```") |> length === 1
@test get_options("```julia, \n```") |> length === 1
@test (:opt => nothing) in get_options("```julia, opt = nothing\n```")
@test (:opt => nothing) in get_options("```{julia, opt = nothing}\n```")
let opts = get_options("```{julia, opt1 = 1, opt2 = \"2\"}\n```")
    @test (:opt1 => 1) in opts
    @test (:opt2 => "2") in opts
end
let opts = get_options("```julia, opt1 = 1, opt2 = \"2\"\n```")
    @test (:opt1 => 1) in opts
    @test (:opt2 => "2") in opts
end
let opts = get_options("```julia{opt1 = 1, opt2 = \"2\"}\n```")
    @test (:opt1 => 1) in opts
    @test (:opt2 => "2") in opts
end

end


@testset "`parse_markdown` pandoc format" begin

get_options(str) =
    (chunk = first(last(parse_markdown(str; is_pandoc = true))); @test hasproperty(chunk, :options); chunk.options)

@test get_options("<<>>=\n@") |> length === 1
@test (:opt => nothing) in get_options("<<opt = nothing>>=\n@")
let opts = get_options("<<opt1 = 1; opt2 = \"2\">>=\n@")
    @test (:opt1 => 1) in opts
    @test (:opt2 => "2") in opts
end
let opts = get_options("<<opt1 = 1, opt2 = \"2\">>=\n@")
    @test (:opt1 => 1) in opts
    @test (:opt2 => "2") in opts
end

end


# TODO: tests for `"script"` format ?
