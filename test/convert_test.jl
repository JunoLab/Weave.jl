using Weave
using Base.Test

function convert_test(outfile, infile="documents/chunk_options.noweb")
  outfile = joinpath("documents/convert", outfile)
  convert_doc(infile, outfile)
  result =  readstring(outfile)
  ref =  readstring(outfile * ".ref")
  @test result == ref
  rm(outfile)
end

convert_test("chunk_options.jmd")
convert_test("chunk_options.jl")
convert_test("chunk_options.mdw")
convert_test("chunk_options_nb.mdw", "documents/chunk_options.ipynb")

# Separate test for notebook (output depends on julia version)
function contents(chunk::Weave.DocChunk)
  return join([strip(c.content) for c in chunk.content], "")
end

function contents(chunk::Weave.CodeChunk)
  return chunk.content
end

function contents(doc::Weave.WeaveDoc)
  return join([contents(chunk) for chunk in doc.chunks], "")
end

outfile = "documents/convert/chunk_options.ipynb"
infile = "documents/chunk_options.noweb"
convert_doc(infile, outfile)
input = contents(Weave.read_doc(infile))
output = contents(Weave.read_doc(outfile))
@test input == output
rm(outfile)

# Test script reader
@test contents(
    Weave.read_doc("documents/chunk_options.noweb")) == contents(
      Weave.read_doc("documents/chunk_options.jl"))

# test custom pre- and post processing
mktempdir(@__DIR__) do dir
  input = joinpath(dir, "input.jl")
  output = joinpath(dir, "output.jl")
  input_str = """
    #' Lorem ipsum
    sum([1, 2, 3, 4])
    #' Lorem ipsum"""
  write(input, input_str)

  convert_doc(input, output, format = "markdown",
    preprocess = str -> (str = replace(str, "Lorem ipsum" => "Real text"); str),
    postprocess = str -> (str = replace(str, "```julia" => "```julia-repl"); str))

  output_str = """
    Real text

    ```julia-repl
    sum([1, 2, 3, 4])
    ```
    Real text
    """
  @test read(output, String) == output_str
end
