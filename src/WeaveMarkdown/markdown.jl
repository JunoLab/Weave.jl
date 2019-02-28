#This module extends the julia markdown parser to improve compatibility with Jupyter, Pandoc etc.
module WeaveMarkdown
using Markdown
import Markdown: @trigger, @breaking, Code, MD, withstream, startswith, LaTeX
using BibTeX

mutable struct Comment
    text::String
end

mutable struct Citation
    key::String
    no::Int64
    bib::Dict
end

Citation(key, no) = Citation(key, no, Dict())

mutable struct Citations
    content::Array{Citation}
end

@breaking true ->
function dollarmath(stream::IO, block::MD)
    withstream(stream) do
        str = Markdown.startswith(stream, r"^\$\$$"m)
        isempty(str) && return false
        trailing = strip(readline(stream))
        buffer = IOBuffer()
        while !eof(stream)
            line_start = position(stream)
            estr = Markdown.startswith(stream, r"^\$\$$"m)
            if !isempty(estr)
                estr = Markdown.startswith(stream, r"^\$\$$"m)
                if isempty(estr)
                    push!(block, LaTeX(String(take!(buffer)) |> chomp))
                end
                return true
            else
                seek(stream, line_start)
            end
            write(buffer, readline(stream, keep=true))
        end
        return false
    end
end

@breaking true ->
function topcomment(stream::IO, block::MD)
    buffer = IOBuffer()
    withstream(stream) do
        str = Markdown.startswith(stream, r"^<!--")
        isempty(str) && return false
        while !eof(stream)
            line = readline(stream, keep=true)
            write(buffer, line)
            if occursin(r"-->$", line)
                s = replace(String(take!(buffer)) |> chomp, r"-->$" => "")
                push!(block, Comment(s))
                return true
            end
        end
        return false
    end
end

@trigger '<' ->
function comment(stream::IO, md::MD)
    withstream(stream) do
        Markdown.startswith(stream, "<!--") || return
        text = Markdown.readuntil(stream, "-->")
        text ≡ nothing && return
        return Comment(text)
    end
end

global const CITATIONS = Dict{Symbol, Any}(
    :no => 1,
    :bibtex => Dict(),
    :references => []
    )

@trigger '[' ->
function citation(stream::IO, md::MD)
    withstream(stream) do
        Markdown.startswith(stream, "[@") || return
        text = Markdown.readuntil(stream, ']', match = '[')
        text ≡ nothing && return
        citations = strip.(split(text, ";"))
        cites = Citation[]
        for c in citations
            c = replace(c, r"^@" => "")
            #Check for matcthing bixtex key
            if haskey(CITATIONS[:bibtex], c)
                bib = CITATIONS[:bibtex][c]
                # Check for repeated citations
                if haskey(CITATIONS[:refnumbers], c)
                    no = CITATIONS[:refnumbers][c]
                else
                    no = CITATIONS[:no]
                    CITATIONS[:refnumbers][c] = no
                    CITATIONS[:no] += 1
                end
                push!(cites, Citation(c, no, bib))
                CITATIONS[:references][c] = bib
            else
                push!(cites, Citation(c, 0))
            end
        end
        return Citations(cites)
    end
end

# Create own flavor and copy all the features from julia flavor
Markdown.@flavor weavemd [dollarmath, comment, topcomment, citation]
weavemd.breaking = [weavemd.breaking; Markdown.julia.breaking]
weavemd.regular = [weavemd.regular; Markdown.julia.regular]
for key in keys(Markdown.julia.inner)
    if haskey(weavemd.inner, key)
        weavemd.inner[key] = [weavemd.inner[key]; Markdown.julia.inner[key]]
    else
        weavemd.inner[key] = Markdown.julia.inner[key]
    end
end

function parse_markdown(text, bibfile)
    CITATIONS[:no] = 1
    header, refs = parse_bibtex(read(bibfile, String))
    CITATIONS[:bibtex] = refs
    CITATIONS[:references] = Dict()
    CITATIONS[:refnumbers] = Dict()
    m = Markdown.parse(text, flavor = weavemd);
    m.content
end


include("html.jl")
include("latex.jl")
end
