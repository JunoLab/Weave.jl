using Weave, Test
using Weave: WeaveDoc, run_doc


# TODO: add test for header processsing
# TODO: add test for `include_weave`

# constructs `WeaveDoc` from `String` and run it
function mock_doc(str; informat = "markdown", run = true, doctype = "md2html", kwargs...)
    f = tempname()
    write(f, str)
    doc = WeaveDoc(f, informat)
    return run ? run_doc(doc; doctype = doctype, kwargs...) : doc
end
macro jmd_str(s) mock_doc(s) end


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
    get(ENV, "CI", nothing) == "true" && begin
        @testset "Plots" begin
            include("plotsjl_test.jl")
        end
        
        @testset "Gadfly" begin
            include("gadfly_formats.jl")
        end
    end

    try
        @testset "end2end (maybe fail)" begin
            include("end2end.jl")
        end
    catch err
        @error err
    end
end
