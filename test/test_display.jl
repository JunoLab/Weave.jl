@testset "limit HMTL output" begin

@static VERSION ≥ v"1.4" && let

# no limit
doc = jmd"""
```julia
using DataFrames
DataFrame(rand(10,3))
```
"""
@test isdefined(doc.chunks[1], :rich_output)
@test count("<tr>", doc.chunks[1].rich_output) == 12 # additonal 2 for name and type row

# limit
n = 100000
doc = jmd"""
```julia
using DataFrames
DataFrame(rand(n,3))
```
"""
@test isdefined(doc.chunks[1], :rich_output)
@test count("<tr>", doc.chunks[1].rich_output) < n

end

end
