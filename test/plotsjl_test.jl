using Weave, Compat
using Base.Test

function pljtest(source, resfile, doctype)
  weave("documents/$source", out_path = "documents/plotsjl/$resfile", doctype=doctype, plotlib=nothing)
  result = @compat readstring(open("documents/plotsjl/$resfile"))
  ref = @compat readstring(open("documents/plotsjl/$resfile.ref"))
  @test result == ref
end

pljtest("plotsjl_test.jmd", "plotsjl_test.md", "pandoc")
pljtest("plotsjl_test.jmd", "plotsjl_test.tex", "tex")
