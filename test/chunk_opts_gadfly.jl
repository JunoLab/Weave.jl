using Weave
using Base.Test

cleanup = true

#Test hold and term options
weave("documents/test_hold.mdw", doctype="pandoc", plotlib="Gadfly")
result =  readstring(open("documents/test_hold.md"))
ref =  readstring(open("documents/test_hold_ref.md"))
@test result == ref
cleanup && rm("documents/test_hold.md")

#Test setting and restoring chunk options
Weave.weave("documents/default_opts.noweb", doctype = "tex")
result =  readstring(open("documents/default_opts.tex"))
ref =  readstring(open("documents/default_opts_ref.tex"))
@test result == ref
cleanup && rm("documents/default_opts.tex")
