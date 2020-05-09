@testset "evaluation module" begin
    function mock_output(document, mod = nothing)
        parsed = Weave.parse_markdown(document)
        doc = Weave.WeaveDoc("dummy.jmd", parsed, Dict())
        result_doc = run_doc(doc, mod = mod)
        @test isdefined(result_doc.chunks[1], :output)
        return result_doc.chunks[1].output
    end

    document = """
    ```julia
    @__MODULE__
    ```
    """

    # in sandbox
    @test occursin(r"\#+WeaveSandBox[\#\d]+", mock_output(document))

    # in Main
    @test strip(mock_output(document, Main)) == "Main"
end

@testset "clear_module!" begin
    ary = rand(1000000)
    size = Base.summarysize(ary)

    # simple case
    m = Core.eval(@__MODULE__, :(module $(gensym(:WeaveTestModule)) end))
    Core.eval(m, :(a = $ary))
    Weave.clear_module!(m)
    @test Base.summarysize(m) < size

    # recursive case
    m = Core.eval(@__MODULE__, :(module $(gensym(:WeaveTestModule)) end))
    Core.eval(m, :(
        module $(gensym(:WeaveTestSubModule))
        a = $ary
        end
    ))
    Weave.clear_module!(m)
    @test Base.summarysize(m) < size

    # doesn't work with constants
    m = Core.eval(@__MODULE__, :(module $(gensym(:WeaveTestModule)) end))
    Core.eval(m, :(const a = $ary))
    Weave.clear_module!(m)
    @test_broken Base.summarysize(m) < size
end
