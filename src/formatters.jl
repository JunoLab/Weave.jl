
#Format the executed document
function format(executed, doctype)
  formatted = String[]
  docformat = formats[doctype]
  #@show docformat
  formatdict = docformat.formatdict
  get!(formatdict, :termstart, formatdict[:codestart])
  get!(formatdict, :termend, formatdict[:codeend])

  for chunk in copy(executed)
      if chunk[:type] == "doc"
          push!(formatted, chunk[:content])
      else
          #Format code
          result = format_codechunk(chunk, formatdict)
          #Handle figures
          if chunk[:fig] && length(chunk[:figure]) > 0
              if chunk[:include]
                  result *= formatfigures(chunk, docformat)
              end
          end
          push!(formatted, result)
      end
  end

 return formatted
end


function format_codechunk(chunk, formatdict)
    if !chunk[:evaluate]
        if chunk[:echo]
            result = "$(formatdict[:codestart])$(chunk[:content])$(formatdict[:codeend])"
            return result
        else
            r = ""
            return r
        end
    end

    if chunk[:term]
        result = format_termchunk(chunk, formatdict)
    else
        if chunk[:echo]
            result = "$(formatdict[:codestart])$(chunk[:content])\n$(formatdict[:codeend])\n"
        else
            result = ""
        end

        if (strip(chunk[:result])!= "") && (chunk[:results] != "hidden")
            #@show chunk
            if chunk[:results] != "verbatim"
                haskey(formatdict, :indent) && (chunk[:result] = indent(chunk[:result]))
                result *= "$(chunk[:result])"
            elseif chunk[:results] == "verbatim"
                result *= "$(formatdict[:outputstart])$(chunk[:result])\n$(formatdict[:outputend])\n"
            end
        end

    end

    return result

end



function format_termchunk(chunk, formatdict)
  if chunk[:echo] && chunk[:results] != "hidden"
    haskey(formatdict, :termindent) && (chunk[:result] = indent(chunk[:result]))
    result = "$(formatdict[:termstart])$(chunk[:result])\n$(formatdict[:termend])\n"
  else
    result = ""
  end
return result
end

function indent(text, nindent)
    return text
end


type Tex
    formatdict::Dict{Symbol,Any}
end

const tex = Tex(@compat Dict{Symbol,Any}(:codestart => "\\begin{juliacode}",
                                         :codeend => "\\end{juliacode}",
                                         :outputstart => "\\begin{juliaout}",
                                         :outputend => "\\end{juliaout}",
                                         :figfmt => ".pdf",
                                         :extension =>"tex",
                                         :width => "\\linewidth",
                                         :doctype => "tex"
                                         ))

const texminted = Tex(@compat Dict{Symbol,Any}(:codestart => "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}",
                                         :codeend => "\\end{minted}",
                                         :outputstart => "\\begin{minted}[fontsize=\\small, xleftmargin=0.5em, mathescape, frame = leftline]{text}",
                                         :outputend => "\\end{minted}",
                                         :termstart=> "\\begin{minted}[fontsize=\\footnotesize, xleftmargin=0.5em, mathescape]{julia}",
                                         :termend => "\\end{minted}",
                                         :figfmt => ".pdf",
                                         :extension =>"tex",
                                         :width => "\\linewidth",
                                         :doctype => "texminted"
                                         ))

type Pandoc
    formatdict::Dict{Symbol,Any}
end

const pandoc = Pandoc(@compat Dict{Symbol,Any}(:codestart => "~~~~{.julia}",
                               :codeend=>"~~~~~~~~~~~~~\n\n",
                               :outputstart=>"~~~~{.julia}",
                               :outputend=>"~~~~~~~~~~~~~\n\n",
                               :figfmt=>".png",
                               :extension=>"md",
                               :width=>"15 cm",
                               :doctype=>"pandoc"
                                               ))


function formatfigures(chunk, docformat::Tex)
    fignames = chunk[:figure]
    caption = chunk[:caption]
    width = get!(chunk, :width, docformat.formatdict[:width])
    f_pos = chunk[:f_pos]
    f_env = chunk[:f_env]
    result = ""
    figstring = ""

    if f_env != nothing
        result *= """\\begin{$f_env}\n"""
    end

    for fig = fignames
        figstring *= "\\includegraphics[width= $width]{$fig}\n"
    end

    # Figure environment
    if caption != nothing
        result *= string("\\begin{figure}[$f_pos]\n",
                         "\\center\n",
                         "$figstring",
                         "\\caption{$caption}\n")
        if chunk[:name] != nothing
            label = chunk[:name]
            result *= "\label{fig:$label}\n"
            result *= "\\end{figure}\n"
        end
    else
        result *= figstring
    end

    if f_env != nothing
        result += "\\end{$f_env}\n"
    end

   return result
end

function formatfigures(chunk, docformat::Pandoc)
    fignames = chunk[:figure]
    caption = chunk[:caption]
    width = get!(chunk, :width, docformat.formatdict[:width])
    result = ""
    figstring = ""

    length(fignames) > 0 || (return "")

    if caption != false
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


#Add new supported formats here
const formats = @compat Dict{String, Any}("tex" => tex,
                                          "texminted" => texminted,
                                          "pandoc" => pandoc)
