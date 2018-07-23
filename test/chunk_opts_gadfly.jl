using Weave
using Test

cleanup = true

#Test hold and term options
weave("documents/test_hold.mdw", doctype="pandoc", plotlib="Gadfly")
result =  read("documents/test_hold.md", String)
ref =  read("documents/test_hold_ref.md", String)
@test result == ref
cleanup && rm("documents/test_hold.md")

#Test setting and restoring chunk options
Weave.weave("documents/default_opts.noweb", doctype = "tex")
result =  read("documents/default_opts.tex", String)
ref =  read("documents/default_opts_ref.tex", String)
@test result == ref
cleanup && rm("documents/default_opts.tex")
