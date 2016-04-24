using Weave, Compat
using Base.Test

cleanup = true

#Test chunk options and output formats
weave("documents/chunk_options.noweb", plotlib=nothing)
result = @compat readstring(open("documents/chunk_options.md"))
ref = @compat readstring(open("documents/chunk_options_ref.md"))
@test result == ref
cleanup && rm("documents/chunk_options.md")

weave("documents/chunk_options.noweb", doctype="tex", plotlib=nothing)
result = @compat readstring(open("documents/chunk_options.tex"))
ref = @compat readstring(open("documents/chunk_options_ref.tex"))
@test result == ref
cleanup && rm("documents/chunk_options.tex")

weave("documents/chunk_options.noweb", doctype="texminted", plotlib=nothing)
result = @compat readstring(open("documents/chunk_options.tex"))
ref = @compat readstring(open("documents/chunk_options_ref.texminted"))
@test result == ref
cleanup && rm("documents/chunk_options.tex")

weave("documents/chunk_options.noweb", doctype="rst", plotlib=nothing)
result = @compat readstring(open("documents/chunk_options.rst"))
ref = @compat readstring(open("documents/chunk_options_ref.rst"))
@test result == ref
cleanup && rm("documents/chunk_options.rst")

#Test out_path
weave("documents/chunk_options.noweb", doctype="rst",
      out_path="documents/outpath_options.rst" , plotlib=nothing)
result = @compat readstring(open("documents/outpath_options.rst"))
ref = @compat readstring(open("documents/chunk_options_ref.rst"))
@test result == ref
cleanup && rm("documents/outpath_options.rst")

#Test tangle
tangle("documents/chunk_options.noweb")
result = @compat readstring(open("documents/chunk_options.jl"))
ref = @compat readstring(open("documents/chunk_options_ref.jl"))
@test result == ref
cleanup && rm("documents/chunk_options.jl")


tangle("documents/chunk_options.noweb", out_path = "documents/outoptions.jl")
result = @compat readstring(open("documents/outoptions.jl"))
ref = @compat readstring(open("documents/chunk_options_ref.jl"))
@test result == ref
cleanup && rm("documents/outoptions.jl")


#Test functions and sandbox clearing
weave("documents/chunk_func.noweb", plotlib=nothing)
result = @compat readstring(open("documents/chunk_func.md"))
ref = @compat readstring(open("documents/chunk_func_ref.md"))
@test result == ref
cleanup && rm("documents/chunk_func.md")
