function get_err_str(str::AbstractString)
    try
        include_string(Main, str)
    catch err
        s = sprint(showerror, err)
        return replace(s, r"in expression starting at .+$" => "") # ignore file
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

```julia; term=true
$err_stmt3
```
"""

err_str1 = get_err_str(err_stmt1)
err_str2 = get_err_str(err_stmt2)
err_str3_1 = get_err_str("plot(x)")
err_str3_2 = get_err_str("f(y")


let doc = mock_run(str; doctype = "github")
    get_output(i) = doc.chunks[i].output

    @test occursin(err_str1, get_output(1))
    @test occursin(err_str2, get_output(2))
    @test occursin(err_str3_1, get_output(3))
    @test occursin(err_str3_2, get_output(3))
end

@test_throws LoadError mock_run(str; doctype = "github", throw_errors = true)

# TODO: test error rendering in `rich_output`
