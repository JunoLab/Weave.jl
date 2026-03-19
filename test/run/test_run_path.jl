@testset "run_path separates execution and output directories" begin

# Create a document that writes a marker file and reads a file from cwd
doc_body = """
```julia
pwd()
```

```julia
read("run_path_input.txt", String)
```
"""

# Set up: doc in one dir, input file in another
doc_dir = mktempdir()
run_dir = mktempdir()
out_dir = mktempdir()

doc_path = joinpath(doc_dir, "test_run_path.jmd")
write(doc_path, doc_body)
write(joinpath(run_dir, "run_path_input.txt"), "hello from run_dir")

@testset "run_path controls execution directory" begin
    doc = run_doc(WeaveDoc(doc_path); out_path = out_dir, run_path = run_dir)
    # pwd() during execution should be run_dir
    @test occursin(run_dir, doc.chunks[1].output)
    # reading a file relative to cwd should find run_dir's file
    @test occursin("hello from run_dir", doc.chunks[2].output)
    # output should go to out_dir
    @test doc.out_dir == out_dir
end

@testset "run_path=:doc runs from document directory" begin
    write(joinpath(doc_dir, "run_path_input.txt"), "hello from doc_dir")
    doc = run_doc(WeaveDoc(doc_path); out_path = out_dir, run_path = :doc)
    @test occursin(doc_dir, doc.chunks[1].output)
    @test occursin("hello from doc_dir", doc.chunks[2].output)
end

@testset "run_path=nothing preserves default behavior" begin
    write(joinpath(out_dir, "run_path_input.txt"), "hello from out_dir")
    doc = run_doc(WeaveDoc(doc_path); out_path = out_dir, run_path = nothing)
    # default: execution dir == output dir
    @test occursin(out_dir, doc.chunks[1].output)
    @test occursin("hello from out_dir", doc.chunks[2].output)
end

@testset "run_path via weave()" begin
    write(joinpath(run_dir, "run_path_input.txt"), "hello from run_dir")
    result_path = weave(doc_path; out_path = out_dir, run_path = run_dir)
    try
        body = read(result_path, String)
        @test occursin(run_dir, body)
        @test occursin("hello from run_dir", body)
    finally
        rm(result_path, force=true)
    end
end

end # @testset
