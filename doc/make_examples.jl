using Weave


weave(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"),
     informat="markdown", out_path = "build/examples", doctype = "pandoc")

 weave(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"),
      informat="markdown", out_path = "build/examples", doctype = "md2html")

weave(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"),
        informat="markdown", out_path = "build/examples", doctype = "md2pdf")

cp(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"),
    "build/examples/gadfly_md_sample.jmd", remove_destination = true)

cp("build/examples/gadfly_md_sample.md",
      "build/examples/gadfly_md_sample.txt", remove_destination = true)

weave(Pkg.dir("Weave","examples","FIR_design.jl"), out_path = "build/examples")
weave(Pkg.dir("Weave","examples","FIR_design.jl"), docformat = "md2pdf", out_path = "build/examples")
cp(Pkg.dir("Weave","examples","FIR_design.jl"),
    "build/examples/FIR_design.jl", remove_destination = true)
