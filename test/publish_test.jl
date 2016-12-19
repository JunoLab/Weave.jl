using Weave
using Base.Test

function publish_test(outfile, format)
  outfile = joinpath("documents/publish", outfile)
  infile = "documents/publish_test.jmd"
  weave(infile, doctype = format, out_path = outfile, template = "templates/mini.tpl")
  result =  readstring(open(outfile))
  ref =  readstring(open(outfile * ".ref"))
  rm(outfile)
  @test result == ref
end

#Test formatters
publish_test("publish_tex.tex", "md2tex")
publish_test("publish_test.html", "md2html")
