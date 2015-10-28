#!/usr/bin/env julia


using Weave
using ArgParse
using Compat

ap = ArgParseSettings("Weave Julia documents using Weave.jl",
                version = string(Pkg.installed("Weave")),
                add_version = true)

@add_arg_table ap begin
    "source"
        nargs = '+'
        help = "source document(s)"
        required = true
    "--doctype"
        arg_type = AbstractString
        default = "pandoc"
        help = "output format"
    "--plotlib"
        arg_type = AbstractString
        default = "Gadfly"
        help = "output format"
    "--informat"
        arg_type = AbstractString
        default = "noweb"
        help = "output format"
    "--out_path"
        arg_type = AbstractString
        default = ":doc"
        help = "output directory"
    "--fig_path"
        arg_type = AbstractString
        default = "figures"
        help = "figure output directory"
    "--fig_ext"
        default = nothing
        help = "figure file format"
end

args = ArgParse.parse_args(ap)
source = args["source"]
delete!(args, "source")
args_col = Dict{Symbol,Any}()

#Check for special values of out_path
if args["out_path"] == ":doc"
    args["out_path"] = :doc
elseif args["out_path"] == ":pwd"
    args["out_path"] = :pwd
end

for (key, val) in args
    args_col[parse(key)] = val
end

for s=source
    weave(s; args_col...)
end
