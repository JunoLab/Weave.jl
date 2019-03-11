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
test_gadfly("pandoc", ".js.svg")
test_gadfly("tex", ".pdf")
test_gadfly("tex", ".png")
test_gadfly("tex", ".ps")
test_gadfly("tex", ".tex")

import Gadfly
p = Gadfly.plot(x=1:10, y=1:10)
@test showable(MIME"application/pdf"(), p) == true
@test showable(MIME"application/png"(), p) == true
