using Weave

weave("../examples/gadfly_md_sample.jmd",
     informat="markdown", out_path = "build/examples", doctype = "pandoc")

 weave("../examples/gadfly_md_sample.jmd",
      informat="markdown", out_path = "build/examples", doctype = "md2html")

weave("../examples/gadfly_md_sample.jmd",
        informat="markdown", out_path = "build/examples", doctype = "md2pdf")

cp("../examples/gadfly_md_sample.jmd",
    "build/examples/gadfly_md_sample.jmd", remove_destination = true)

cp("build/examples/gadfly_md_sample.md",
      "build/examples/gadfly_md_sample.txt", remove_destination = true)

weave("../examples/FIR_design.jl", out_path = "build/examples")
weave("../examples/FIR_design.jl", doctype = "md2pdf", out_path = "build/examples")
cp("../examples/FIR_design.jl",
    "build/examples/FIR_design.jl", remove_destination = true)
