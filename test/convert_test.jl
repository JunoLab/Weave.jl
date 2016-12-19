using Weave
using Base.Test

function convert_test(outfile)
  outfile = joinpath("documents/convert", outfile)
  infile = "documents/chunk_options.noweb"
  convert_doc(infile, outfile)
  result =  readstring(open(outfile))
  ref =  readstring(open(outfile * ".ref"))
  rm(outfile)
  @test result == ref
end

convert_test("chunk_options.jmd")
convert_test("chunk_options.jl")
convert_test("chunk_options.mdw")
convert_test("chunk_options.ipynb")

function convert_test_nb(outfile)
  outfile = joinpath("documents/convert", outfile)
  infile = "documents/chunk_options.ipynb"
  convert_doc(infile, outfile)
  result =  readstring(open(outfile))
  ref =  readstring(open(outfile * ".ref"))
  rm(outfile)
  @test result == ref
end

convert_test_nb("chunk_options_nb.mdw")
