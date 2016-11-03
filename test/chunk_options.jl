using Weave
using Base.Test

cleanup = true

#Test chunk options and output formats
weave("documents/chunk_options.noweb", plotlib=nothing)
result =  readstring(open("documents/chunk_options.md"))
ref =  readstring(open("documents/chunk_options_ref.md"))
@test result == ref
cleanup && rm("documents/chunk_options.md")

weave("documents/chunk_options.noweb", doctype="tex", plotlib=nothing)
result =  readstring(open("documents/chunk_options.tex"))
ref =  readstring(open("documents/chunk_options_ref.tex"))
@test result == ref
cleanup && rm("documents/chunk_options.tex")

weave("documents/chunk_options.noweb", doctype="texminted", plotlib=nothing)
result =  readstring(open("documents/chunk_options.tex"))
ref =  readstring(open("documents/chunk_options_ref.texminted"))
@test result == ref
cleanup && rm("documents/chunk_options.tex")

weave("documents/chunk_options.noweb", doctype="rst", plotlib=nothing)
result =  readstring(open("documents/chunk_options.rst"))
ref =  readstring(open("documents/chunk_options_ref.rst"))
@test result == ref
cleanup && rm("documents/chunk_options.rst")

#Test out_path
weave("documents/chunk_options.noweb", doctype="rst",
      out_path="documents/outpath_options.rst" , plotlib=nothing)
result =  readstring(open("documents/outpath_options.rst"))
ref =  readstring(open("documents/chunk_options_ref.rst"))
@test result == ref
cleanup && rm("documents/outpath_options.rst")

#Test tangle
tangle("documents/chunk_options.noweb")
result =  readstring(open("documents/chunk_options.jl"))
ref =  readstring(open("documents/chunk_options_ref.jl"))
@test result == ref
cleanup && rm("documents/chunk_options.jl")


tangle("documents/chunk_options.noweb", out_path = "documents/outoptions.jl")
result =  readstring(open("documents/outoptions.jl"))
ref =  readstring(open("documents/chunk_options_ref.jl"))
@test result == ref
cleanup && rm("documents/outoptions.jl")


#Test functions and sandbox clearing
weave("documents/chunk_func.noweb", plotlib=nothing)
result =  readstring(open("documents/chunk_func.md"))
ref =  readstring(open("documents/chunk_func_ref.md"))
@test result == ref
cleanup && rm("documents/chunk_func.md")

#Test term=true
weave("documents/test_term.jmd", doctype = "pandoc")
result =  readstring(open("documents/test_term.md"))
ref =  readstring(open("documents/test_term_ref.md"))
@test result == ref
cleanup && rm("documents/test_term.md")
