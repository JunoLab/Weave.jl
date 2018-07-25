using Weave
using Test

function weavestring(source; doctype = "pandoc", informat="markdown", mod=Main)
    p1 = Weave.parse_doc(source, informat)
    doc = Weave.WeaveDoc("dummy1.jmd", p1, Dict())
    return Weave.run(doc, doctype=doctype, mod=mod)
end

smod = """
```julia
module TestMod
    x = 3

    function printx()
        print("x")
    end

    export printx
end
```

```julia
using .TestMod
printx()
```
"""

wdoc = weavestring(smod)
@test wdoc.chunks[1].output == "Main.TestMod\n"
@test wdoc.chunks[2].output == "x"

sdoc = weavestring(smod, mod=:sandbox)
@test occursin(r"Main.WeaveSandBox[0-9]*.TestMod\n", sdoc.chunks[1].output)
@test sdoc.chunks[2].output == "x"
