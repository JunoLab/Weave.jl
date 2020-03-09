dir = @__DIR__
refjmd = joinpath(dir, "documents", "jupyter_test.jmd")
testjmd = joinpath(dir, "documents", "output_as_code.jmd")


Weave.weave(refjmd, doctype="pandoc")
refresult =  read(joinpath(dir, "documents", "jupyter_test.md"), String)

Weave.weave(testjmd, doctype="pandoc",
            args=Dict("filename" => joinpath(dir, "documents", "codefile.jl")))
result =  read(joinpath(dir, "documents", "output_as_code.md"), String)

@test result == refresult

