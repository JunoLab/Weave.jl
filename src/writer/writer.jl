function write_doc(doc, rendered, out_path)
    return write_doc(doc.format, doc, rendered, out_path)
end

function write_doc(::WeaveFormat, doc, rendered, out_path)
    write(out_path, rendered)
    return out_path
end

include("pandoc.jl")
include("latex.jl")
