

"""
`pandoc2html(formatted::AbstractString)`

Convert output from pandoc markdown to html using Weave.jl template
"""
function pandoc2html(formatted::AbstractString, doc::WeaveDoc)
  html_template = joinpath(Pkg.dir("Weave"), "templates/pandoc_skeleton.html")
  css_template = joinpath(Pkg.dir("Weave"), "templates/pandoc_skeleton.css")

  path, wsource = splitdir(abspath(doc.source))
  wversion = string(Pkg.installed("Weave"))
  wtime =  Date(now())

  #Change path for pandoc
  old_wd = pwd()
  cd(doc.cwd)

  html = readall(pipeline(`echo $formatted` ,
   `pandoc -R -s --mathjax --self-contained --template
    $html_template --include-in-header=$css_template -V wversion=$wversion -V wtime=$wtime -V wsource=$wsource`)
    )

  cd(old_wd)
  return(html)
end
