using Weave
using Base.Test

function pljtest(source, resfile, doctype)
  weave("documents/$source", out_path = "documents/plotsjl/$resfile", doctype=doctype)
  result =  readstring(open("documents/plotsjl/$resfile"))
  ref =  readstring(open("documents/plotsjl/$resfile.ref"))
  @test result == ref
end

pljtest("plotsjl_test.jmd", "plotsjl_test.md", "pandoc")
pljtest("plotsjl_test.jmd", "plotsjl_test.tex", "tex")

pljtest("plotsjl_test_gr.jmd", "plotsjl_test_gr.md", "pandoc")
