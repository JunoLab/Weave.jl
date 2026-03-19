@testset "evaluation error handling" begin

using Weave: unwrap_load_err


function get_err_str(str::AbstractString)
    try
        include_string(Main, str)
    catch _err
        err = unwrap_load_err(_err)
        return sprint(showerror, err)
    end
end

err_stmt1 = "using NonExisting"
err_stmt2 = "x = "
err_stmt3 = """
plot(x)
y = 10
f(y
"""

str = """
```julia
$err_stmt1
```

```julia
$err_stmt2
```

```julia; term = true
$err_stmt3
```
"""

err_str1 = get_err_str(err_stmt1)
err_str2 = get_err_str(err_stmt2)
err_str3_1 = get_err_str("plot(x)")
err_str3_2 = get_err_str("f(y")

# Julia 1.12+ error messages include source locations and module names that
# differ between include_string (used above) and Weave's execution context
# (temp files, sandbox module). Normalize these before comparing.
function normalize_err(s::AbstractString)
    # ParseError locations: "@ string:1:5" (include_string) vs "@ /tmp/...:2:5" (Weave temp file)
    s = replace(s, r"@ .+?:\d+:\d+" => "@ <loc>")
    # UndefVarError module: "Main" (include_string) vs "Main.var\"##WeaveSandBox#N\"" (Weave sandbox)
    s = replace(s, r"Main\.var\"##WeaveSandBox#\d+\"" => "Main")
    # Weave uses display(err) while get_err_str uses showerror — these produce
    # different whitespace in ParseError diagnostics. Collapse whitespace so
    # the semantic content can be compared.
    s = replace(s, r"\s+" => " ")
    return s
end

let doc = mock_run(str; doctype = "github")
    get_output(i) = doc.chunks[i].output

    @test occursin(err_str1, get_output(1))
    @test occursin(normalize_err(err_str2), normalize_err(get_output(2)))
    @test occursin(normalize_err(err_str3_1), normalize_err(get_output(3)))
    @test occursin(normalize_err(err_str3_2), normalize_err(get_output(3)))
end

# TODO: move this into chunk option tests
str = """
```julia; error = true
using  # won't be thrown
```

```julia; error = false
using NonExisting # will be thrown
```
"""

@test_throws ArgumentError mock_run(str; doctype = "github")

end  # @testset "evaluation error handling"
