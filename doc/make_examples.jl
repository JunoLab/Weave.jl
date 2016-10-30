using Weave


weave(joinpath(dirname(@__FILE__),"..","examples","gadfly_md_sample.jmd"),
     informat="markdown", out_path = "build/examples", doctype = "pandoc")

 weave(joinpath(dirname(@__FILE__),"..","examples","gadfly_md_sample.jmd"),
      informat="markdown", out_path = "build/examples", doctype = "md2html")

weave(joinpath(dirname(@__FILE__),"..","examples","gadfly_md_sample.jmd"),
        informat="markdown", out_path = "build/examples", doctype = "md2pdf")

cp(joinpath(dirname(@__FILE__),"..","examples","gadfly_md_sample.jmd"),
    "build/examples/gadfly_md_sample.jmd", remove_destination = true)

cp("build/examples/gadfly_md_sample.md",
      "build/examples/gadfly_md_sample.txt", remove_destination = true)

weave(joinpath(dirname(@__FILE__),"..","examples","FIR_design.jl"), out_path = "build/examples")
weave(joinpath(dirname(@__FILE__),"..","examples","FIR_design.jl"), doctype = "md2pdf", out_path = "build/examples")
cp(joinpath(dirname(@__FILE__),"..","examples","FIR_design.jl"),
    "build/examples/FIR_design.jl", remove_destination = true)
