using Weave
using Weave: run_doc
using Test


# TODO: add test for header processsing
# TODO: add test for `include_weave`


@testset "Weave" begin
    @testset "Chunk options" begin
        include("chunk_options.jl")
    end

    @testset "Error handling " begin
        include("errors_test.jl")
    end

    @testset "module evaluation" begin
        include("test_module_evaluation.jl")
    end

    @testset "header" begin
        include("test_header.jl")
    end

    @testset "Conversions" begin
        include("convert_test.jl")
    end

    @testset "Formatters" begin
        include("formatter_test.jl")
        include("markdown_test.jl")
        include("figureformatter_test.jl")
    end

    @testset "Rich output" begin
        include("rich_output.jl")
    end

    @testset "Plots" begin
        include("plotsjl_test.jl")
    end

    @testset "Cache" begin
        include("cache_test.jl")
    end

    @testset "Gadfly" begin
        include("gadfly_formats.jl")
    end

    @testset "Inline code" begin
        include("inline_test.jl")
    end

    # @testset "Notebooks" begin
    #     @info("Testing Jupyter options")
    #     include("notebooks.jl")
    # end
end
