@testset "unicode to latex conversion" begin
    unicode2latex(args...) = Weave.unicode2latex(get_format("md2tex"), args...)

    # unit test
    let
        s = unicode2latex("α = 10")
        @test !occursin("α", s)
        @test occursin("alpha", s)
    end

    # end2end
    let
        str = """
        ```julia
        α = 10
        ```
        """
        doc = mock_run(str; doctype = "md2tex")
        Weave.set_format_options!(doc.format)
        rendered = Weave.render_doc(doc)
        @test occursin("alpha", rendered)
        @test !occursin("α", rendered)

        doc = mock_run(str; doctype = "md2tex")
        Weave.set_format_options!(doc.format; keep_unicode = true)
        rendered = Weave.render_doc(doc)
        @test !occursin("alpha", rendered)
        @test occursin("α", rendered)
    end
end  # @testset "rendering tex formats"
