import Markdown: latex, latexinline

function latex(io::IO, tex::Markdown.LaTeX)
    math_envs = ["align", "equation", "eqnarray"]
    use_dollars = !any([occursin("\\begin{$me", tex.formula) for me in math_envs])
    use_dollars && write(io, "\\[")
    write(io, string("\n", tex.formula, "\n"))
    use_dollars && write(io, "\\]\n")
end

#Remove comments that can occur inside a line
function latexinline(io, comment::WeaveMarkdown.Comment)
    write(io, "")
end

function latex(io::IO, comment::WeaveMarkdown.Comment)
    for line in split(comment.text, r"\r\n|\n")
        write(io, "% $line\n")
    end
end
