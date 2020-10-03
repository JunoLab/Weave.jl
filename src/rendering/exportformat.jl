abstract type ExportFormat <: WeaveFormat end

function Base.getproperty(sf::T, s::Symbol) where {T<:ExportFormat}
    hasfield(T, s) && return getfield(sf, s)
    return getproperty(sf.primaryformat, s)
end
function Base.setproperty!(sf::T, s::Symbol, v) where {T<:ExportFormat}
    if hasfield(T, s)
        setfield!(sf, s, v)
    else
        setproperty!(sf.primaryformat, s, v)
    end
end
function Base.hasproperty(sf::T, s::Symbol) where {T<:ExportFormat}
    hasfield(T, s) || hasproperty(sf.primaryformat, s)
end

render_doc(df::ExportFormat, body, doc) = render_doc(df.primaryformat, body, doc)

render_chunk(df::ExportFormat, chunk) = render_chunk(df.primaryformat, chunk)
# Need to define these to avoid ambiguities
render_chunk(df::ExportFormat, chunk::DocChunk) = render_chunk(df.primaryformat, chunk)
render_chunk(df::ExportFormat, chunk::CodeChunk) = render_chunk(df.primaryformat, chunk)
render_output(df::ExportFormat, output) = render_output(df.primaryformat, output)
