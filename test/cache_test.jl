using Weave
using Test

#Test if running document with and without cache works
isdir("documents/cache") && rm("documents/cache", recursive = true)
weave("documents/chunk_options.noweb", cache=:all)
result =  read("documents/chunk_options.md", String)
rm("documents/chunk_options.md")
weave("documents/chunk_options.noweb", cache=:all)
cached_result =  read("documents/chunk_options.md", String)
@test result == cached_result

# cache = :user
isdir("documents/cache") && rm("documents/cache", recursive = true)
out = "documents/chunk_cache.md"
Weave.weave("documents/chunk_cache.noweb", cache=:user);
result =  read(out, String)
rm(out)
Weave.weave("documents/chunk_cache.noweb", cache=:user);
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
