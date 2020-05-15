# TODO: refactor

function convert_test(outfile, infile="documents/chunk_options.noweb")
  outfile = joinpath("documents/convert", outfile)
  convert_doc(infile, outfile)
  result =  read(outfile, String)
  ref =  read(outfile * ".ref", String)
  @test result == ref
  rm(outfile)
end

convert_test("chunk_options.jmd")
convert_test("chunk_options.jl")
convert_test("chunk_options.mdw")
convert_test("chunk_options_nb.mdw", "documents/chunk_options.ipynb")

# Separate test for notebook (output depends on julia version)
contents(chunk::Weave.DocChunk) = join([strip(c.content) for c in chunk.content], "")
contents(chunk::Weave.CodeChunk) = chunk.content
contents(doc::Weave.WeaveDoc) = join([contents(chunk) for chunk in doc.chunks], "")

outfile = "documents/convert/chunk_options.ipynb"
infile = "documents/chunk_options.noweb"
convert_doc(infile, outfile)
input = contents(Weave.WeaveDoc(infile))
output = contents(Weave.WeaveDoc(outfile))
@test input == output
rm(outfile)

# Test script reader
@test contents(Weave.WeaveDoc("documents/chunk_options.noweb")) == contents(Weave.WeaveDoc("documents/chunk_options.jl"))
