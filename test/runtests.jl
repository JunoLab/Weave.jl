using Weave
using Test

@testset "Weave" begin
    @testset "Chunk options" begin
        @info("Test: Chunk options")
        include("chunk_options.jl")
    end

    @testset "Error handling " begin
        @info("Testing error handling")
        include("errors_test.jl")
    end

    @testset "Eval in module" begin
        include("sandbox_test.jl")
    end

    @testset "Conversions" begin
        @info("Test: Converting")
        include("convert_test.jl")
    end

    @testset "Formatters" begin
        @info("Testing formatters")
        include("formatter_test.jl")
        include("markdown_test.jl")
        @info("Testing figure formatters")
        include("figureformatter_test.jl")
    end

    @testset "Rich output" begin
        @info("Testing rich output")
        include("rich_output.jl")
    end

    @testset "Plots" begin
        @info("Test: Weaving with Plots.jl")
        include("plotsjl_test.jl")
    end

    @testset "Cache" begin
        @info("Testing cache")
        include("cache_test.jl")
    end

    @testset "Gadfly" begin
        @info("Test: Weaving with Gadfly.jl")
        include("gadfly_formats.jl")
    end

    @testset "Header options" begin
        @info("Testing header options")
        include("options_test.jl")
    end

    @testset "Inline code" begin
        @info("Testing inline code")
        include("inline_test.jl")
    end

    # @testset "Notebooks" begin
    #     @info("Testing Jupyter options")
    #     include("notebooks.jl")
    # end
end
