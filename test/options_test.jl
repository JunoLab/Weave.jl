using Weave, Test, YAML

header = YAML.load("""
---
options:
    out_path: reports
    md2html:
        out_path : html/
    md2pdf:
        out_path : pdf/
    github:
        out_path : md/
    fig_ext : .png
---
""")

args = header["options"]
@test Weave.combine_args(args, "md2html") == Dict("fig_ext" => ".png",
                                            "out_path" => "html/")
@test Weave.combine_args(args, "github") == Dict("fig_ext" => ".png",
                                            "out_path" => "md/")
@test Weave.combine_args(args, "pandoc") == Dict("fig_ext" => ".png",
                                                "out_path" => "reports")
doc = Weave.read_doc(joinpath(@__DIR__, "documents", "header_test.jmd"))
@test doc.chunk_defaults[:echo] == false
@test doc.chunk_defaults[:out_width] == "30%"
