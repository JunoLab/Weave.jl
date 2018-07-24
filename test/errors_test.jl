using Weave
using Test

s1= """

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

p1 = Weave.parse_doc(s1, "markdown")
doc = Weave.WeaveDoc("dummy1.jmd", p1, Dict())
doc1 = Weave.run(doc, doctype = "pandoc")

@test doc1.chunks[1].output == "Error: ArgumentError: Package Weave does not have NonExisting in its dependencies:\n - If you have Weave checked out for development and have\n   added NonExisting as a dependency but haven't updated your primary\n   environment's manifest file, try `Pkg.resolve()`.\n - Otherwise you may need to report an issue with Weave.\n\n"
@test doc1.chunks[2].output == "Error: syntax: incomplete: premature end of input\n"
@test doc1.chunks[3].output == "\njulia> plot(x)\nError: UndefVarError: plot not defined\n\njulia> y = 10\n10\n\njulia> print(y\nError: syntax: incomplete: premature end of input\n"

try
    doc2 = Weave.run(doc, doctype = "pandoc", throw_errors = true)
catch E
    @test typeof(E) == ArgumentError
    @test E.msg == "Package Weave does not have NonExisting in its dependencies:\n - If you have Weave checked out for development and have\n   added NonExisting as a dependency but haven't updated your primary\n   environment's manifest file, try `Pkg.resolve()`.\n - Otherwise you may need to report an issue with Weave.\n"
end

doc = Weave.WeaveDoc("dummy1.jmd", p1, Dict())
doc3 = Weave.run(doc, doctype = "md2html")
@test doc3.chunks[1].rich_output == "<pre class=\"julia-error\">\nERROR: ArgumentError: Package Weave does not have NonExisting in its dependencies:\n - If you have Weave checked out for development and have\n   added NonExisting as a dependency but haven&#39;t updated your primary\n   environment&#39;s manifest file, try &#96;Pkg.resolve&#40;&#41;&#96;.\n - Otherwise you may need to report an issue with Weave.\n\n</pre>\n"
@test doc3.chunks[2].rich_output == "<pre class=\"julia-error\">\nERROR: syntax: incomplete: premature end of input\n</pre>\n"
@test doc3.chunks[3].output == "\njulia> plot(x)\nError: UndefVarError: plot not defined\n\njulia> y = 10\n10\n\njulia> print(y\nError: syntax: incomplete: premature end of input\n"
@test doc3.chunks[3].rich_output == ""
