using Weave

let start_dir = pwd()
    cd(@__DIR__)

    weave("../examples/FIR_design.jmd", doctype = "pandoc", out_path = "build/examples")
    weave("../examples/FIR_design.jmd", doctype = "md2html", out_path = "build/examples")
    weave("../examples/FIR_design_plots.jl", doctype = "md2html", out_path = "build/examples")

    # PDF outputs
    try
        weave("../examples/FIR_design.jmd", doctype = "md2pdf", out_path = "assets")
        weave("../examples/FIR_design_plots.jl", doctype = "md2pdf", out_path = "assets")
    catch err
        @error err
    end

    cp("../examples/FIR_design.jmd", "build/examples/FIR_design.jmd", force = true)
    cp("build/examples/FIR_design.md", "build/examples/FIR_design.txt", force = true)
    cp("../examples/FIR_design_plots.jl", "build/examples/FIR_design_plots.jl", force = true)

    cd(start_dir)
end
