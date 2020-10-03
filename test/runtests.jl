# TODO:
# - reorganize this
# - test for `include_weave`
# - fire horrible tests
# - test for ipynb integration
# - test for integrations with other libraries, especially for Plots.jl and Gadfly.jl

# %%
using Weave, Test
using Weave: WeaveDoc, run_doc, get_format


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

    @testset "render" begin
        include("render/texformats.jl")
    end

    @testset "conversions" begin
        include("test_converter.jl")
    end

    @testset "display" begin
        include("test_display.jl")
    end

    @testset "end2end" begin
        include("end2end/test_end2end.jl")
    end

    @testset "legacy" begin
        include("markdown_test.jl")
        include("render_figures_test.jl")
        include("cache_test.jl")
    end
end
