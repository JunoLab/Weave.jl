import Mustache

function list_references(m::MIME"text/html")
    tpl = Mustache.template_from_file(joinpath(@__DIR__, "../../templates/html_citations.tpl"))
    refs = Dict()
    for key in keys(CITATIONS[:refnumbers])
        refs[CITATIONS[:refnumbers][key]] = key
    end
    io = IOBuffer()
    write(io, "<h3>References</h3>")
    write(io, "<ol>")
    for i in 1:length(refs)
        ref = CITATIONS[:references][refs[i]]
        ref[ref["type"]] = "true"
        ref["author"] = replace(ref["author"], r"\sand\s"i => ", ")
        for key in keys(ref)
            ref[key] = replace(ref[key], r"\{|\}" => "")
            ref[key] = replace(ref[key], "--" => "&ndash;")
        end
        write(io, "<li>")
        write(io, Mustache.render(tpl, ref))
        write(io, "</li>")
    end
    write(io, "</ol>")
    return String(take!(io))
end
