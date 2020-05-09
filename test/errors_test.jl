str = """

```julia
using NonExisting
```

```julia
x =
```


```julia;term=true
plot(x)
y = 10
print(y
```

"""

let
    doc = run_doc(mock_doc(str), doctype = "pandoc")
    @test doc.chunks[1].output == "Error: ArgumentError: Package NonExisting not found in current path:\n- Run `import Pkg; Pkg.add(\"NonExisting\")` to install the NonExisting package.\n\n"
    @test doc.chunks[2].output == "Error: syntax: incomplete: premature end of input\n"
    @test doc.chunks[3].output == "\njulia> plot(x)\nError: UndefVarError: plot not defined\n\njulia> y = 10\n10\n\njulia> print(y\nError: syntax: incomplete: premature end of input\n"
end

@test_throws ArgumentError run_doc(mock_doc(str), doctype = "pandoc", throw_errors = true)

let
    doc = run_doc(mock_doc(str), doctype = "md2html")
    @test doc.chunks[1].rich_output == "<pre class=\"julia-error\">\nERROR: ArgumentError: Package NonExisting not found in current path:\n- Run &#96;import Pkg; Pkg.add&#40;&quot;NonExisting&quot;&#41;&#96; to install the NonExisting package.\n\n</pre>\n"
    @test doc.chunks[2].rich_output == "<pre class=\"julia-error\">\nERROR: syntax: incomplete: premature end of input\n</pre>\n"
    @test doc.chunks[3].output == "\njulia> plot(x)\nError: UndefVarError: plot not defined\n\njulia> y = 10\n10\n\njulia> print(y\nError: syntax: incomplete: premature end of input\n"
    @test doc.chunks[3].rich_output == ""
end
