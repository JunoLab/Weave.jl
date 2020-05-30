# TODO:
# - 1. do assertions for definition mandatory fields in `@define_format` macro
# - 2. implement fallback format/rendering functions in format.jl
# - 3. export this as public API


abstract type WeaveFormat end
const FORMATS = Dict{String,WeaveFormat}()

macro define_format(ex)
    return if ex isa Symbol
        quote
            struct $(ex) <: $(WeaveFormat)
                formatdict::Dict{Symbol,Any}
            end
        end
    elseif Meta.isexpr(ex, :<:)
        type_name, supertype = ex.args
        quote
            @assert $(esc(supertype)) <: $(WeaveFormat) "$($(esc(supertype))) should be subtype of WeaveFormat"
            struct $(type_name) <: $(esc(supertype))
                formatdict::Dict{Symbol,Any}
            end
        end
    else
        error("@define_format expects T or T<:S expression")
    end
end
# TODO: do some assertion for necessary fields of `formatdict`
register_format!(format_name::AbstractString, format::WeaveFormat) = push!(FORMATS, format_name => format)
