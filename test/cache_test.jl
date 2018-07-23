using Weave
using Test

#Test if running document with and without cache works
isdir("documents/cache") && rm("documents/cache", recursive = true)
weave("documents/chunk_options.noweb", plotlib=nothing, cache=:all)
result =  read("documents/chunk_options.md", String)
rm("documents/chunk_options.md")
weave("documents/chunk_options.noweb", plotlib=nothing, cache=:all)
cached_result =  read("documents/chunk_options.md", String)
@test result == cached_result

# cache = :user
isdir("documents/cache") && rm("documents/cache", recursive = true)
out = "documents/chunk_cache.md"
Weave.weave("documents/chunk_cache.noweb", plotlib=nothing, cache=:user);
result =  read(out, String)
rm(out)
Weave.weave("documents/chunk_cache.noweb", plotlib=nothing, cache=:user);
cached_result =  read(out, String)
@test result == cached_result

# cache = :all
isdir("documents/cache") && rm("documents/cache", recursive = true)
out = "documents/chunk_cache.md"
Weave.weave("documents/chunk_cache.noweb", cache=:all);
result =  read(out, String)
rm(out)
Weave.weave("documents/chunk_cache.noweb", cache=:all);
cached_result =  read(out, String)
@test result == cached_result



if VERSION.minor == 5
  using Gadfly
  isdir("documents/cache") && rm("documents/cache", recursive = true)
  #Caching with Gadfly
  weave("documents/gadfly_formats_test.txt", doctype="tex", plotlib="gadfly", cache=:all)
  result =  read("documents/gadfly_formats_test.tex", String)
  rm("documents/gadfly_formats_test.tex")
  weave("documents/gadfly_formats_test.txt", doctype="tex", plotlib="gadfly", cache=:all)
  cached_result =  read("documents/gadfly_formats_test.tex", String)
  @test result == cached_result
end
