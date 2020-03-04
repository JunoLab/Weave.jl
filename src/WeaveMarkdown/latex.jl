import Markdown: latex, latexinline

# Remove comments that can occur inside a line
function latexinline(io, comment::WeaveMarkdown.Comment)
    write(io, "")
end

function latex(io::IO, comment::WeaveMarkdown.Comment)
    for line in split(comment.text, r"\r\n|\n")
        write(io, "% $line\n")
    end
end
