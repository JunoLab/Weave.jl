using Weave
using Test

function pljtest(source, resfile, doctype)
  weave("documents/$source", out_path = "documents/plotsjl/$resfile", doctype=doctype)
  result =  read("documents/plotsjl/$resfile", String)
  ref =  read("documents/plotsjl/$resfile.ref", String)
  @test result == ref
  rm("documents/plotsjl/$resfile")
end

pljtest("plotsjl_test_gr.jmd", "plotsjl_test_gr.md", "pandoc")
pljtest("plotsjl_test_gr.jmd", "plotsjl_test_gr.tex", "tex")

# test cache with plots
isdir("documents/cache") && rm("documents/cache", recursive = true)
weave("documents/plotsjl_test_gr.jmd", cache=:all)
result =  read("documents/plotsjl_test_gr.html", String)
rm("documents/plotsjl_test_gr.html")
weave("documents/plotsjl_test_gr.jmd", cache=:all)
cached_result =  read("documents/plotsjl_test_gr.html", String)
@test result == cached_result
