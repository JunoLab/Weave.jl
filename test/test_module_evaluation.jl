# TODO: test `clear_module!`

function mock_output(document, mod = nothing)
    parsed = Weave.parse_doc(document, "markdown")
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
