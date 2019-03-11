#Test for Gadfly with different chunk options and figure formatsusing Weave
using Weave
using Test

function test_gadfly(doctype, fig_ext)
    out = weave(joinpath(@__DIR__ , "documents/gadfly_formats_test.jnw"),
        out_path = joinpath(@__DIR__ , "documents/gadfly/"),
        doctype = doctype, fig_ext = fig_ext)
    result = read(out, String)
    #cp(out, out*fig_ext*"."*doctype, force=true) # Used when adding new tests
    ref =  read(out*fig_ext*"."*doctype, String)
    @test result == ref
    rm(out)
end

##
test_gadfly("github", ".png")
test_gadfly("github", ".pdf")
test_gadfly("github", ".svg")
test_gadfly("pandoc", ".png")
test_gadfly("tex", ".pdf")
test_gadfly("tex", ".png")


##
# weave("documents/gadfly_formats_test.txt", doctype="tex", fig_ext=".tex", plotlib="gadfly")
# result =  read("documents/gadfly_formats_test.tex", String)
# ref =  read("documents/gadfly_formats_test_tikz_ref.tex", String)
# @test result == ref
#
# weave("documents/gadfly_formats_test.txt", doctype="tex", fig_ext=".ps", plotlib="gadfly")
# result =  read("documents/gadfly_formats_test.tex", String)
# ref =  read("documents/gadfly_formats_test_ps_ref.tex", String)
# @test result == ref
#
# weave("documents/gadfly_formats_test.txt", doctype="pandoc", plotlib="gadfly")
# result =  read("documents/gadfly_formats_test.md", String)
# ref =  read("documents/gadfly_formats_test_pandoc_ref.md", String)
# @test result == ref
#
# weave("documents/gadfly_formats_test.txt", doctype="pandoc", plotlib="gadfly", fig_ext=".svg")
# result =  read("documents/gadfly_formats_test.md", String)
# ref =  read("documents/gadfly_formats_test_svg_ref.md", String)
# @test result == ref
#
# weave("documents/gadfly_formats_test.txt", doctype="github", plotlib="gadfly", fig_ext=".js.svg")
# result =  read("documents/gadfly_formats_test.md", String)
# ref =  read("documents/gadfly_formats_test_jssvg_ref.md", String)
# @test result == ref
#
# weave("documents/gadfly_formats_test.txt", doctype="rst", plotlib="gadfly")
# result =  read("documents/gadfly_formats_test.rst", String)
# ref =  read("documents/gadfly_formats_test_ref.rst", String)
# @test result == ref
#
# weave("documents/gadfly_formats_test.txt", doctype="multimarkdown", plotlib="gadfly")
# result =  read("documents/gadfly_formats_test.md", String)
# ref =  read("documents/gadfly_formats_test_mmd_ref.md", String)
# @test result == ref
#
# weave("documents/gadfly_formats_test.txt", doctype="asciidoc", plotlib="gadfly",
#     out_path="documents/output")
# result =  read("documents/output/gadfly_formats_test.txt", String)
# ref =  read("documents/output/gadfly_formats_test_ref.txt", String)
# @test result == ref
#
# weave("documents/gadfly_markdown_test.jmd", doctype="github",plotlib="gadfly", informat="markdown")
# result =  read("documents/gadfly_markdown_test.md", String)
# ref =  read("documents/gadfly_markdown_test_ref.md", String)
# @test result == ref
#
# weave("documents/FIR_design.jl", doctype="pandoc", plotlib="gadfly", informat="script")
# result =  read("documents/FIR_design.md", String)
# ref =  read("documents/FIR_design_ref.md", String)
# @test result == ref
