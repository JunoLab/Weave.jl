import Markdown: latex, latexinline

function latex(io::IO, comment::Comment)
    for line in split(comment.text, r"\r\n|\n")
        write(io, "% $line\n")
    end
end

latexinline(io, comment::Comment) = write(io, "")
