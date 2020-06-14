# TODO:
# - 1. Improve argument handling
# - 2. Update code to use UnPack.jl to make it more readable
# - 3. Export new interface
# - 4. Document Interface

using Mustache, Highlights, .WeaveMarkdown, Markdown, Dates, Printf


const FORMATS = Dict{String,WeaveFormat}()

# TODO: do some assertion for necessary fields of `format`
register_format!(format_name::AbstractString, format::WeaveFormat) = push!(FORMATS, format_name => format)
register_format!(_, format) = error("Format needs to be a subtype of WeaveFormat.")

set_format_options!(doc; kwargs...) = set_format_options!(doc.format; kwargs...)

function render_doc(doc::WeaveDoc)
    restore_header!(doc)

    docformat = doc.format
    body = joinlines(render_chunk.(Ref(docformat), copy(doc.chunks)))
    return render_doc(docformat, body, doc)
end


include("common.jl")
include("htmlformats.jl")
include("texformats.jl")
include("pandocformats.jl")
include("miscformats.jl")
