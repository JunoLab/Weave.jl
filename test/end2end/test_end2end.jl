# NOTE:
# This test file does end to end tests, while we don't want to check the details in the generated documents.
# Rather, we just assert we can `weave` all the supported formats without errors here.

# TODO:
# - more complex example
# - integration with other libraries, like Plots

@testset "end2end simple" begin
    include("test_simple.jl")
end  # @testset "end2end"
