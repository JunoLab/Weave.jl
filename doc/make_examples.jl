using Weave
start_dir = pwd()
cd(@__DIR__)

weave("../examples/FIR_design.jmd",
     informat="markdown", out_path = "build/examples", doctype = "pandoc")

weave("../examples/FIR_design.jmd",
      informat="markdown", out_path = "build/examples", doctype = "md2html")

cp("../examples/FIR_design.jmd",
    "build/examples/FIR_design.jmd", force = true)

cp("build/examples/FIR_design.md",
      "build/examples/FIR_design.txt", force = true)

weave("../examples/FIR_design_plots.jl", out_path = "build/examples")

cp("../examples/FIR_design_plots.jl",
    "build/examples/FIR_design_plots.jl", force = true)

if !haskey(ENV, "TRAVIS")
    weave("../examples/FIR_design.jmd",
        informat="markdown", out_path = "build/examples", doctype = "md2pdf")
    weave("../examples/FIR_design_plots.jl", doctype = "md2pdf", out_path = "build/examples")
end


cd(start_dir)
