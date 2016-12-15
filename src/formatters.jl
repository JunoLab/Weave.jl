type Tex
    description::AbstractString
    formatdict::Dict{Symbol,Any}
end

const tex = Tex("Latex with custom code environments",
                Dict{Symbol,Any}(:codestart => "\\begin{juliacode}",
                                         :codeend => "\\end{juliacode}",
                                         :outputstart => "\\begin{juliaout}",
                                         :outputend => "\\end{juliaout}",
                                         :termstart => "\\begin{juliaterm}",
                                         :termend => "\\end{juliaterm}",
                                         :fig_ext => ".pdf",
                                         :extension =>"tex",
                                         :out_width=> "\\linewidth",
                                         :fig_env=> "figure",
                                         :fig_pos => "htpb",
                                         :doctype => "tex",
                                         :mimetypes => ["application/pdf", "image/png", "text/latex", "text/plain"]
                                         ))

const texminted = Tex("Latex using minted for highlighting",
                      Dict{Symbol,Any}(
                                         :codestart => "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}",
                                         :codeend => "\\end{minted}",
                                         :outputstart => "\\begin{minted}[fontsize=\\small, xleftmargin=0.5em, mathescape, frame = leftline]{text}",
                                         :outputend => "\\end{minted}",
                                         :termstart=> "\\begin{minted}[fontsize=\\footnotesize, xleftmargin=0.5em, mathescape]{julia}",
                                         :termend => "\\end{minted}",
                                         :fig_ext => ".pdf",
                                         :extension =>"tex",
                                         :out_width => "\\linewidth",
                                         :fig_env=> "figure",
                                         :fig_pos => "htpb",
                                         :doctype => "texminted",
                                         :mimetypes => ["application/pdf", "image/png", "text/latex", "text/plain"]
                                         ))

type Pandoc
  description::AbstractString
  formatdict::Dict{Symbol,Any}
end


const pandoc = Pandoc("Pandoc markdown",
                        Dict{Symbol,Any}(
                                :codestart => "~~~~{.julia}",
                                :codeend=>"~~~~~~~~~~~~~\n\n",
                                :outputstart=>"~~~~",
                                :outputend=>"~~~~\n\n",
                                :fig_ext=>".png",
                                :out_width=>nothing,
                                :extension=>"md",
                                #Prefer png figures for markdown conversion, svg doesn't work with latex
                                :mimetypes => ["image/png", "image/jpg", "image/svg+xml", "text/markdown", "text/plain"],
                                :doctype=>"pandoc"
                                               ))


const pdoc2html = Pandoc("Markdown to HTML (requires Pandoc)",
                      Dict{Symbol,Any}(
                              :codestart => "````julia",
                              :codeend=> "````\n\n",
                              :outputstart=> "````",
                              :outputend=> "````\n\n",
                              :fig_ext=> ".svg",
                              :extension=> "md",
                              :mimetypes => ["image/svg+xml", "image/png", "image/jpg",
                                  "text/html", "text/markdown",  "text/plain"],
                              :doctype=> "md2html"))

type Markdown
   description::AbstractString
   formatdict::Dict{Symbol,Any}
end

const github = Markdown("Github markdown",
                        Dict{Symbol,Any}(
                                :codestart => "````julia",
                                :codeend=> "````\n\n",
                                :outputstart=> "````",
                                :outputend=> "````\n\n",
                                :fig_ext=> ".png",
                                :extension=> "md",
                                :doctype=> "github"
                                               ))

#Julia markdown
type JMarkdown2HTML
 description::AbstractString
 formatdict::Dict{Symbol,Any}
end

const md2html = JMarkdown2HTML("Julia markdown to html", Dict{Symbol,Any}(
        :codestart => "\n",
        :codeend=> "\n",
        :outputstart=> "<pre class=\"hljl\">",
        :outputend=> "</pre>\n",
        :fig_ext=> ".png",
        :extension=> "html",
        :doctype=> "md2html"))

#Julia markdown
type JMarkdown2tex
 description::AbstractString
 formatdict::Dict{Symbol,Any}
end

const md2tex = JMarkdown2tex("Julia markdown to latex", Dict{Symbol,Any}(
        :codestart => "",
        :codeend=> "",
        :outputstart=> "\\begin{lstlisting}",
        :outputend=> "\\end{lstlisting}\n",
        :fig_ext=> ".pdf",
        :extension=> "tex",
        :mimetypes => ["application/pdf", "image/png", "image/jpg",
                       "text/latex", "text/plain"],
        :doctype=> "md2tex"))


type MultiMarkdown
  description::AbstractString
  formatdict::Dict{Symbol,Any}
end

function img_to_base64(fig, ext, cwd)
  f = open(joinpath(cwd, fig), "r")
    raw = read(f)
  close(f)
  if ext == ".png"
    return "data:image/png;base64," * stringmime(MIME("image/png"), raw)
  elseif ext == ".svg"
    return "data:image/svg+xml;base64," * stringmime(MIME("image/svg+xml"), raw)
  else
    return(fig)
  end
end

function formatfigures(chunk, docformat::JMarkdown2HTML)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    height = chunk.options[:out_height]
    f_pos = chunk.options[:fig_pos]
    f_env = chunk.options[:fig_env]
    result = ""
    figstring = ""

    #Set size
    attribs = ""
    width == nothing || (attribs = "width=\"$width\"")
    (attribs != "" && height != nothing ) && (attribs *= ",")
    height == nothing  || (attribs *= " height=\"$height\" ")

    if caption != nothing
        result *= """<figure>\n"""
    end

    for fig = fignames
      ext = splitext(fig)[2]
      if ext == ".png" || ext == ".svg"
        fig = img_to_base64(fig, ext, docformat.formatdict[:cwd])
      end

      figstring *= """<img src="$fig" $attribs />\n"""
    end

    result *= figstring

    if caption != nothing
        result *= """
          <figcaption>$caption</figcaption>
          """
    end

    if caption != nothing
        result *= "</figure>\n"
    end

   return result
end

const multimarkdown = MultiMarkdown("MultiMarkdown",
                        Dict{Symbol,Any}(
                                :codestart => "````julia",
                                :codeend=> "````\n\n",
                                :outputstart=> "````",
                                :outputend=> "````\n\n",
                                :fig_ext=> ".png",
                                :extension=> "md",
                                :doctype=> "github"
                                               ))


type Rest
    description::AbstractString
    formatdict::Dict{Symbol,Any}
end

const rst = Rest("reStructuredText and Sphinx",
                    Dict{Symbol,Any}(
                                :codestart => ".. code-block:: julia\n",
                                :codeend => "\n\n",
                                :outputstart => "::\n",
                                :outputend => "\n\n",
                                :indent=> 4,
                                :fig_ext => ".png",
                                :extension => "rst",
                                :out_width => "15 cm",
                                :doctype => "rst"
                                ))

type AsciiDoc
    description::AbstractString
    formatdict::Dict{Symbol,Any}
end

#asciidoc -b html5 -a source-highlighter=pygments ...
const adoc = AsciiDoc("AsciiDoc",
        Dict{Symbol,Any}(
        :codestart => "[source,julia]\n--------------------------------------",
        :codeend => "--------------------------------------\n\n",
        :outputstart => "--------------------------------------",
        :outputend => "--------------------------------------\n\n",
        :fig_ext => ".png",
        :extension => "txt",
        :out_width => "600",
        :doctype => "asciidoc"
))


function formatfigures(chunk, docformat::Tex)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    height = chunk.options[:out_height]
    f_pos = chunk.options[:fig_pos]
    f_env = chunk.options[:fig_env]
    result = ""
    figstring = ""

    #Set size
    attribs = ""
    width == nothing || (attribs = "width=$width")
    (attribs != "" && height != nothing ) && (attribs *= ",")
    height == nothing    || (attribs *= "height=$height")


    if f_env != nothing
        result *= """\\begin{$f_env}[$f_pos]\n"""
    end


    for fig = fignames


        if splitext(fig)[2] == ".tex" #Tikz figures
            figstring *= "\\resizebox{$width}{!}{\\input{$fig}}\n"
        else
            figstring *= "\\includegraphics[$attribs]{$fig}\n"
        end
    end

    # Figure environment
    if caption != nothing
        result *= string("\\center\n",
                         "$figstring",
                         "\\caption{$caption}\n")
    else
        result *= figstring
    end

    if chunk.options[:name] != nothing && f_env !=nothing
        label = chunk.options[:name]
        result *= "\\label{fig:$label}\n"
    end


    if f_env != nothing
        result *= "\\end{$f_env}\n"
    end

   return result
end

function formatfigures(chunk, docformat::Pandoc)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    result = ""
    figstring = ""
    attribs = ""
    width = chunk.options[:out_width]
    height = chunk.options[:out_height]

    #Build figure attibutes
    width == nothing || (attribs = "width=$width")
    (attribs ≠ "" && height ≠ nothing ) && (attribs *= " ")
    height == nothing   || (attribs *= "height=$height")
    attribs == ""    || (attribs = "{$attribs}")
    length(fignames) > 0 || (return "")

    if caption != nothing
        result *= "![$caption]($(fignames[1]))$attribs\n"
        for fig = fignames[2:end]
            result *= "![]($fig)$attribs\n"
            println("Warning, only the first figure gets a caption\n")
        end
    else
        for fig in fignames
            result *= "![]($fig)$attribs\\ \n\n"
        end
    end
    return result
end

function formatfigures(chunk, docformat::Markdown)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    result = ""
    figstring = ""

    length(fignames) > 0 || (return "")

    if caption != nothing
        result *= "![$caption]($(fignames[1]))\n"
        for fig = fignames[2:end]
            result *= "![]($fig)\n"
            println("Warning, only the first figure gets a caption\n")
        end
    else
        for fig in fignames
            result *= "![]($fig)\n"
        end
    end
    return result
end

function formatfigures(chunk, docformat::MultiMarkdown)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    result = ""
    figstring = ""

    if chunk.options[:out_width] == nothing
      width = ""
    else
      width = "width=$(chunk.options[:out_width])"
    end

    length(fignames) > 0 || (return "")

    if caption != nothing
       result *= "![$caption][$(fignames[1])]\n\n"
       result *= "[$(fignames[1])]: $(fignames[1]) $width\n"
        for fig = fignames[2:end]
          result *= "![][$fig]\n\n"
          result *= "[$fig]: $fig $width\n"
          println("Warning, only the first figure gets a caption\n")
        end
    else
        for fig in fignames
          result *= "![][$fig]\n\n"
          result *= "[$fig]: $fig $width\n"
        end
    end
    return result
end


function formatfigures(chunk, docformat::Rest)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    result = ""
    figstring = ""

    for fig=fignames
        figstring *= @sprintf(".. image:: %s\n   :width: %s\n\n", fig, width)
    end

    if caption != nothing
        result *= string(".. figure:: $(fignames[1])\n",
                         "   :width: $width\n\n",
                         "   $caption\n\n")
    else
        result *= figstring
        return result
    end
end


function formatfigures(chunk, docformat::AsciiDoc)
    fignames = chunk.figures
    caption = chunk.options[:fig_cap]
    width = chunk.options[:out_width]
    result = ""
    figstring = ""


    for fig=fignames
        figstring *= @sprintf("image::%s[width=%s]\n", fig, width)
    end


    if caption != nothing
        result *= string("image::$(fignames[1])",
        "[width=$width,",
        "title=\"$caption\"]")
    else
        result *= figstring
        return result
    end
end


#Add new supported formats here
const formats = Dict{AbstractString, Any}("tex" => tex,
                                          "texminted" => texminted,
                                          "pandoc" => pandoc,
                                          "pandoc2html" => pdoc2html,
                                          "md2pdf" => md2tex,
                                          "github" => github,
                                          "multimarkdown" => multimarkdown,
                                          "rst" => rst,
                                          "asciidoc" => adoc,
                                          "md2html" => md2html,
                                          "md2tex" => md2tex
                                          )
