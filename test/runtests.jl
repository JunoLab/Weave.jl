using Weave, Test
using Weave: WeaveDoc, run_doc


# TODO: add test for header processsing
# TODO: add test for `include_weave`

function mock_doc(str, informat = "markdown")
    f = tempname()
    write(f, str)
    return WeaveDoc(f, informat)
end
mock_run(str, informat = "markdown"; kwargs...) = run_doc(mock_doc(str, informat); kwargs...)

function test_mock_weave(test_function, str; kwargs...)
    f = tempname()
    write(f, str)
    f = weave(f; kwargs...)
    try
        weave_body = read(f, String)
        test_function(weave_body)
    catch
        rethrow()
    finally
        rm(f)
    end
end


@testset "Weave" begin
    @testset "module evaluation" begin
        include("test_module_evaluation.jl")
    end

    @testset "header" begin
        include("test_header.jl")
    end

    @testset "inline" begin
        include("test_inline.jl")
    end

    @testset "chunk options" begin
        include("test_chunk_options.jl")
    end

    @testset "error rendering" begin
        include("test_error_rendering.jl")
    end

    @testset "conversions" begin
        include("test_converter.jl")
    end

    @testset "display" begin
        include("test_display.jl")
    end

    @testset "Formatters" begin
        include("formatter_test.jl")
        include("markdown_test.jl")
        include("figureformatter_test.jl")
    end

    @testset "Rich output" begin
        include("rich_output.jl")
    end

    @testset "Cache" begin
        include("cache_test.jl")
    end

    # @testset "Notebooks" begin
    #     @info("Testing Jupyter options")
    #     include("notebooks.jl")
    # end

    # trigger only on CI
    if get(ENV, "CI", nothing) == "true"
        @testset "Plots" begin
            include("plotsjl_test.jl")
        end

        @testset "Gadfly" begin
            include("gadfly_formats.jl")
        end
    else
        @info "skipped Plots.jl and Gadfly.jl integration test"
    end

    try
        @testset "end2end (maybe fail)" begin
            include("end2end.jl")
        end
    catch err
        @error err
    end
end
