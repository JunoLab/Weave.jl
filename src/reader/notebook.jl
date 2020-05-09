"""
    parse_notebook(document_body)::Vector{WeaveChunk}

Parses Jupyter notebook and returns [`WeaveChunk`](@ref)s.
"""
function parse_notebook(document_body)::Vector{WeaveChunk}
    nb = JSON.parse(document_body)
    chunks = WeaveChunk[]
    options = Dict{Symbol,Any}()
    opt_string = ""
    docno = 1
    codeno = 1

    for cell in nb["cells"]
        srctext = "\n" * join(cell["source"], "")

        if cell["cell_type"] == "code"
            chunk = CodeChunk(rstrip(srctext), codeno, 0, opt_string, options)
            push!(chunks, chunk)
            codeno += 1
        else
            chunk = DocChunk(srctext * "\n", docno, 0; notebook = true)
            push!(chunks, chunk)
            docno += 1
        end
    end

    return chunks
end
