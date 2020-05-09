using Weave.YAML

# TODO:
# - header stripping
# - header parsing from a Weave document


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

let args = header[Weave.WEAVE_OPTION_NAME]
    @test Weave.combine_args(args, "md2html") == Dict("fig_ext" => ".png", "out_path" => "html/")
    @test Weave.combine_args(args, "github") == Dict("fig_ext" => ".png", "out_path" => "md/")
    @test Weave.combine_args(args, "pandoc") == Dict("fig_ext" => ".png", "out_path" => "reports")
end
