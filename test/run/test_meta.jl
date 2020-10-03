@testset "meta information for evaluation" begin

doc_body = """
```julia
include("test_include.jl")
```

```julia
@__MODULE__
```

```julia
@__DIR__
```

```julia
@__FILE__
```

```julia
@__LINE__ # broken
```

```julia
read("./test_include.jl", String)
```
"""
doc_dir = normpath(@__DIR__, "..", "mocks")
doc_path = normpath(doc_dir, "test_meta.jmd")
write(doc_path, doc_body)

script_line = ":include_me"
script_body = "$script_line"
script_path = normpath(@__DIR__, "..", "mocks", "test_include.jl")
write(script_path, script_body)


m = Core.eval(@__MODULE__, :(module $(gensym(:WeaveTestModule)) end))
mock = run_doc(WeaveDoc(doc_path); mod = m)
check_output(i, s) = occursin(s, mock.chunks[i].output)

@test check_output(1, script_line)
@test check_output(2, string(m))
@test check_output(3, doc_dir)
@test check_output(4, doc_path)
@test_broken check_output(5, 18)
@test check_output(6, string('"', script_line, '"')) # current working directory

end  # @testset "meta information for evaluation"
