using Weave, Compat
using Base.Test

#Test if running document with and without cache works
isdir("documents/cache") && rm("documents/cache", recursive = true)
weave("documents/chunk_options.noweb", plotlib=nothing, cache=:all)
result = @compat readstring(open("documents/chunk_options.md"))
rm("documents/chunk_options.md")
weave("documents/chunk_options.noweb", plotlib=nothing, cache=:all)
cached_result = @compat readstring(open("documents/chunk_options.md"))
@test result == cached_result

# cache = :user
isdir("documents/cache") && rm("documents/cache", recursive = true)
out = "documents/chunk_cache.md"
Weave.weave("documents/chunk_cache.noweb", plotlib=nothing, cache=:user);
result = @compat readstring(open(out))
rm(out)
Weave.weave("documents/chunk_cache.noweb", plotlib=nothing, cache=:user);
cached_result = @compat readstring(open(out))
@test result == cached_result

if VERSION.minor == 3
  using Gadfly
  isdir("documents/cache") && rm("documents/cache", recursive = true)
  #Caching with Gadfly
  weave("documents/gadfly_formats_test.txt", doctype="tex", plotlib="gadfly", cache=:all)
  result = @compat readstring(open("documents/gadfly_formats_test.tex"))
  rm("documents/gadfly_formats_test.tex")
  weave("documents/gadfly_formats_test.txt", doctype="tex", plotlib="gadfly", cache=:all)
  cached_result = @compat readstring(open("documents/gadfly_formats_test.tex"))
  @test result == cached_result
end
