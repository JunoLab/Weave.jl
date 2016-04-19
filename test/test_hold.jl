using Weave
using Base.Test

cleanup = true

#Test hold and term options
weave("documents/test_hold.mdw", doctype="pandoc", plotlib="Gadfly")
result = readall(open("documents/test_hold.md"))
ref = readall(open("documents/test_hold_ref.md"))
@test result == ref
cleanup && rm("documents/test_hold.md")
