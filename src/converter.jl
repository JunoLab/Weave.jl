using JSON, Mustache

"""
    convert_doc(infile::AbstractString, outfile::AbstractString; outformat::Union{Nothing,AbstractString} = nothing)

Convert Weave documents between different formats

- `infile`: Path of the input document
- `outfile`: Path of the output document
- `outformat = nothing`: Output document format (optional). By default (i.e. given `nothing`) Weave will try to automatically detect it from the `outfile`'s extension. You can also specify either of `"script"`, `"markdown"`, `"notebook"`, or `"noweb"`
"""
function convert_doc(
    infile::AbstractString,
    outfile::AbstractString;
    outformat::Union{Nothing,AbstractString} = nothing,
)
    doc = WeaveDoc(infile)

    if isnothing(outformat)
        ext = lowercase(splitext(outfile)[2])
        outformat =
            ext == ".jl" ? "script" :
            ext == ".jmd" ?  "markdown" :
            ext == ".ipynb" ? "notebook" :
            "noweb" # fallback
    end

    converted = _convert_doc(doc, outformat)

    open(outfile, "w") do f
        write(f, converted)
    end
    return outfile
end

function _convert_doc(doc, outformat)
    outformat == "script" ? convert_to_script(doc) :
    outformat == "markdown" ? convert_to_markdown(doc) :
    outformat == "notebook" ? convert_to_notebook(doc) :
    convert_to_noweb(doc)
end

function convert_to_script(doc)
    output = ""
    for chunk in doc.chunks
        if typeof(chunk) == Weave.DocChunk
            content = join([repr(c) for c in chunk.content], "")
            output *= join(["#' " * s for s in split(content, "\n")], "\n")
        else
            output *= "\n#+ "
            isempty(chunk.optionstring) || (output *= strip(chunk.optionstring))
            output *= "\n\n" * lstrip(chunk.content)
            output *= "\n"
        end
    end

    return output
end

function convert_to_markdown(doc)
    output = ""
    for chunk in doc.chunks
        if isa(chunk, DocChunk)
            output *= join([repr(c) for c in chunk.content], "")
        else
            output *= "\n" * "```julia"
            isempty(chunk.optionstring) || (output *= ";" * chunk.optionstring)
            output *= "\n" * lstrip(chunk.content)
            output *= "```\n"
        end
    end

    return output
end

function convert_to_notebook(doc)
    nb = Dict()
    nb["nbformat"] = 4
    nb["nbformat_minor"] = 2
    metadata = Dict()
    kernelspec = Dict()
    kernelspec["language"] = "julia"
    kernelspec["name"] = "julia-$(VERSION.major).$(VERSION.minor)"
    kernelspec["display_name"] = "Julia $(VERSION.major).$(VERSION.minor).$(VERSION.patch)"
    metadata["kernelspec"] = kernelspec
    language_info = Dict()
    language_info["file_extension"] = ".jl"
    language_info["mimetype"] = "application/julia"
    language_info["name"] = "julia"
    language_info["version"] = "$(VERSION.major).$(VERSION.minor).$(VERSION.patch)"
    metadata["language_info"] = language_info
    cells = []
    ex_count = 1

    for chunk in doc.chunks
        if isa(chunk, DocChunk)
            push!(
                cells,
                Dict(
                    "cell_type" => "markdown",
                    "metadata" => Dict(),
                    "source" => [strip(join([repr(c) for c in chunk.content], ""))],
                ),
            )
        elseif haskey(chunk.options, :skip) && chunk.options[:skip] == "notebook"
            continue
        else
            push!(
                cells,
                Dict(
                    "cell_type" => "code",
                    "metadata" => Dict(),
                    "source" => [strip(chunk.content)],
                    "execution_count" => nothing,
                    "outputs" => [],
                ),
            )
        end
    end

    nb["cells"] = cells
    nb["metadata"] = metadata

    json_nb = JSON.json(nb, 2)
    return json_nb
end

function convert_to_noweb(doc)
    output = ""
    for chunk in doc.chunks
        if isa(chunk, DocChunk)
            output *= join([repr(c) for c in chunk.content], "")
        else
            output *= "\n" * "<<"
            isempty(chunk.optionstring) || (output *= strip(chunk.optionstring))
            output *= ">>="
            output *= "\n" * lstrip(chunk.content)
            output *= "@\n"
        end
    end

    return output
end

Base.repr(c::InlineText) = c.content
Base.repr(c::InlineCode) = "`j $(c.content)`"
