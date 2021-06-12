module RelocatableFolders

import Scratch, SHA

export @folder_str

macro folder_str(path)
    dir = string(__source__.file)
    dir = isfile(dir) ? dirname(dir) : pwd()
    return :($(Folder)($__module__, $dir, $(esc(path))))
end

struct Folder <: AbstractString
    mod::Module
    path::String
    hash::String
    files::Dict{String,Vector{UInt8}}

    function Folder(mod::Module, dir, path::AbstractString)
        path = isabspath(path) ? path : normpath(joinpath(dir, path))
        isdir(path) || throw(ArgumentError("not a directory: `$path`"))
        files = Dict{String,Vector{UInt8}}()
        ctx = SHA.SHA1_CTX()
        for (root, _, fs) in walkdir(path), f in fs
            fullpath = joinpath(root, f)
            include_dependency(fullpath)
            SHA.update!(ctx, codeunits(fullpath))
            content = read(fullpath)
            SHA.update!(ctx, content)
            files[relpath(fullpath, path)] = content
        end
        return new(mod, path, string(Base.SHA1(SHA.digest!(ctx))), files)
    end
end

Base.show(io::IO, path::Folder) = print(io, repr(path.path))
Base.ncodeunits(f::Folder) = ncodeunits(getpath(f))
Base.isvalid(f::Folder, index::Integer) = isvalid(getpath(f), index)
Base.iterate(f::Folder) = iterate(getpath(f))
Base.iterate(f::Folder, state::Integer) = iterate(getpath(f), state)
Base.String(f::Folder) = String(getpath(f))

function getpath(f::Folder)
    isdir(f.path) && return f.path
    dir = Scratch.get_scratch!(f.mod, f.hash)
    if !isempty(f.files) && !ispath(joinpath(dir, first(keys(f.files))))
        cd(dir) do
            for (file, blob) in f.files
                mkpath(dirname(file))
                write(file, blob)
            end
        end
    end
    return dir
end

end # module
