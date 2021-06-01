# This module extends the julia markdown parser to improve compatibility with Jupyter, Pandoc etc.
module WeaveMarkdown

using ..Weave: isnothing, take2string!
using Markdown
import Markdown: @trigger, @breaking, Code, MD, withstream, startswith, LaTeX

# HACK: that this definition is type-piracy. It is required since `Markdown`
# does not have a built in system for contextual rendering by users. `io` here
# should always be either `IOBuffer` or `IOContext` since it is reached via
# `sprint` in all user-facing code paths in `Markdown`.
function Markdown.latex(io::Union{IOBuffer,IOContext}, tex::Markdown.LaTeX)
    math_envs = ["align", "equation", "eqnarray"]
    use_dollars =
        !any([occursin("\\begin{$me", tex.formula) for me in math_envs])
    use_dollars && write(io, "\\[")
    write(io, string("\n", tex.formula, "\n"))
    use_dollars && write(io, "\\]\n")
end

mutable struct Comment
    text::String
end

@breaking true -> function dollarmath(stream::IO, block::MD)
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
                    push!(block, LaTeX(take2string!(buffer) |> chomp))
                end
                return true
            else
                seek(stream, line_start)
            end
            write(buffer, readline(stream, keep = true))
        end
        return false
    end
end

@breaking true -> function topcomment(stream::IO, block::MD)
    buffer = IOBuffer()
    withstream(stream) do
        str = Markdown.startswith(stream, r"^<!--")
        isempty(str) && return false
        while !eof(stream)
            line = readline(stream, keep = true)
            write(buffer, line)
            if occursin(r"-->$", line)
                s = replace(take2string!(buffer) |> chomp, r"-->$" => "")
                push!(block, Comment(s))
                return true
            end
        end
        return false
    end
end

@trigger '<' -> function comment(stream::IO, md::MD)
    withstream(stream) do
        Markdown.startswith(stream, "<!--") || return
        text = Markdown.readuntil(stream, "-->")
        isnothing(text) && return
        return Comment(text)
    end
end

# Create own flavor and copy all the features from julia flavor
Markdown.@flavor weavemd [dollarmath, comment, topcomment]
weavemd.breaking = [weavemd.breaking; Markdown.julia.breaking]
weavemd.regular = [weavemd.regular; Markdown.julia.regular]
for key in keys(Markdown.julia.inner)
    if haskey(weavemd.inner, key)
        weavemd.inner[key] = [weavemd.inner[key]; Markdown.julia.inner[key]]
    else
        weavemd.inner[key] = Markdown.julia.inner[key]
    end
end


include("html.jl")
include("latex.jl")

end  # module
