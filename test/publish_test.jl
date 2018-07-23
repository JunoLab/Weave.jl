using Weave
using Test
import Plots

function publish_test(outfile, format)
  outfile = joinpath("documents/publish", outfile)
  infile = "documents/publish_test.jmd"
  weave(infile, doctype = format, out_path = outfile, template = "templates/mini.tpl")
  result =  read(outfile, String)
  ref =  read(outfile * ".ref", String)
  @test result == ref
  rm(outfile)
end

#Test formatters
publish_test("publish_tex.tex", "md2tex")
#!is_windows() && publish_test("publish_test.html", "md2html")
