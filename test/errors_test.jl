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

doc1.chunks[1].output

@test doc1.chunks[1].output == "Error: ArgumentError: Package NonExisting not found in current path:\n- Run `import Pkg; Pkg.add(\"NonExisting\")` to install the NonExisting package.\n\n"
@test doc1.chunks[2].output == "Error: syntax: incomplete: premature end of input\n"
@test doc1.chunks[3].output == "\njulia> plot(x)\nError: UndefVarError: plot not defined\n\njulia> y = 10\n10\n\njulia> print(y\nError: syntax: incomplete: premature end of input\n"

@test_throws ArgumentError Weave.run(doc, doctype = "pandoc", throw_errors = true)

doc = Weave.WeaveDoc("dummy1.jmd", p1, Dict())
doc3 = Weave.run(doc, doctype = "md2html")
@test doc3.chunks[1].rich_output == "<pre class=\"julia-error\">\nERROR: ArgumentError: Package NonExisting not found in current path:\n- Run &#96;import Pkg; Pkg.add&#40;&quot;NonExisting&quot;&#41;&#96; to install the NonExisting package.\n\n</pre>\n"
@test doc3.chunks[2].rich_output == "<pre class=\"julia-error\">\nERROR: syntax: incomplete: premature end of input\n</pre>\n"
@test doc3.chunks[3].output == "\njulia> plot(x)\nError: UndefVarError: plot not defined\n\njulia> y = 10\n10\n\njulia> print(y\nError: syntax: incomplete: premature end of input\n"
@test doc3.chunks[3].rich_output == ""
