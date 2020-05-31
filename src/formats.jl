# TODO:
# - 1. do assertions for definition mandatory fields in `@define_format` macro
# - 2. implement fallback format/rendering functions in format.jl
# - 3. export this as public API


abstract type WeaveFormat end
const FORMATS = Dict{String,WeaveFormat}()

# TODO: do some assertion for necessary fields of `format`
register_format!(format_name::AbstractString, format::WeaveFormat) = push!(FORMATS, format_name => format)
register_format!(_,format) = error("Format needs to be a subtype of WeaveFormat.")
