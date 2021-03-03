@testset "module evaluation" begin

function mock_output(str, mod = nothing)
    result_doc = mock_run(str; mod = mod)
    return result_doc.chunks[1].output
end

str = """
```julia
@__MODULE__
```
"""

# in sandbox
@test occursin(r"\#+WeaveSandBox[\#\d]+", mock_output(str))

# in Main
@test strip(mock_output(str, Main)) == "Main"

end # @testset "module evaluation"

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

julia_markdown_body = """
this is just to test the `out_path` option
"""

f_in = tempname()
f_out = tempname() * ".md"
write(f_in, julia_markdown_body)
f = weave(f_in; out_path=f_out)
@test isfile(f_out)

end # @testset "clear_module!"
