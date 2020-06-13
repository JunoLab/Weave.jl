# TODO:
# - reorganize this
# - test for `include_weave`
# - fire horrible tests
# - test for ipynb integration

# %%
using Weave, Test
using Weave: WeaveDoc, run_doc


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


# %%
@testset "Weave" begin
    @testset "reader" begin
        include("reader/test_chunk_options.jl")
        include("reader/test_inline.jl")
    end

    @testset "header processing" begin
        include("test_header.jl")
    end

    @testset "run" begin
        include("run/test_module.jl")
        include("run/test_meta.jl")
        include("run/test_error.jl")
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

    @testset "cache" begin
        include("cache_test.jl")
    end

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
end
