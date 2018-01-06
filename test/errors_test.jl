using Weave
using Base.Test

s1= """

```julia
using NonExisting
```

```julia
x =
```

"""

p1 = Weave.parse_doc(s1, "markdown")
doc1 = Weave.WeaveDoc("dummy1.jmd", p1, Dict())
doc1 = Weave.run(doc1, doctype = "pandoc")

@test doc1.chunks[1].output == "ArgumentError(\"Module NonExisting not found in current path.\\nRun `Pkg.add(\\\"NonExisting\\\")` to install the NonExisting package.\")\n"
@test doc1.chunks[2].output == "ErrorException(\"syntax: incomplete: premature end of input\")\n"

try
    doc2 = Weave.run(doc1, doctype = "pandoc", throw_errors = true)
catch E
    @show dump(E)
end