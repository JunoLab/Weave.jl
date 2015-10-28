using Weave
using Base.Test

cleanup = true

#Test if running document with and without cache works
isdir("documents/cache") && rm("documents/cache", recursive = true)
weave("documents/chunk_options.noweb", plotlib=nothing, cache=:all)
result = readall(open("documents/chunk_options.md"))
rm("documents/chunk_options.md")
weave("documents/chunk_options.noweb", plotlib=nothing, cache=:all)
cached_result = readall(open("documents/chunk_options.md"))
@test result == cached_result
cleanup && rm("documents/chunk_options.md")

# cache = :user
isdir("documents/cache") && rm("documents/cache", recursive = true)
out = "documents/chunk_cache.md"
Weave.weave("documents/chunk_cache.noweb", plotlib=nothing, cache=:user);
result = readall(open(out))
rm(out)
Weave.weave("documents/chunk_cache.noweb", plotlib=nothing, cache=:user);
cached_result = readall(open(out))
@test result == cached_result
cleanup && rm(out)

if VERSION.minor == 3
  using Gadfly
  isdir("documents/cache") && rm("documents/cache", recursive = true)
  #Caching with Gadfly
  weave("documents/gadfly_formats_test.txt", doctype="tex", plotlib="gadfly", cache=:all)
  result = readall(open("documents/gadfly_formats_test.tex"))
  rm("documents/gadfly_formats_test.tex")
  weave("documents/gadfly_formats_test.txt", doctype="tex", plotlib="gadfly", cache=:all)
  cached_result = readall(open("documents/gadfly_formats_test.tex"))
  @test result == cached_result
  cleanup && rm("documents/gadfly_formats_test.tex")
end

cleanup && rm("documents/cache", recursive = true)
