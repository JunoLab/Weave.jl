using JSON


function parse_notebook(document_body)
    nb = JSON.parse(document_body)
    code_no = 0
    doc_no = 0

    # TODO: handle some of options ?
    options = Dict{Symbol,Any}(:softscope => true)
    opt_string = ""

    chunks = map(nb["cells"]) do cell
        text = string('\n', join(cell["source"]), '\n')
        return if cell["cell_type"] == "code"
            CodeChunk(text, code_no += 1, 0, opt_string, options)
        else
            DocChunk(text, doc_no += 1, 0; notebook = true)
        end
    end

    return Dict(), chunks
end
