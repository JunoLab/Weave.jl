

"""
`pandoc2html(formatted::AbstractString, doc::WeaveDoc)`

Convert output from pandoc markdown to html using Weave.jl template
"""
function pandoc2html(formatted::AbstractString, doc::WeaveDoc)
  html_template = joinpath(Pkg.dir("Weave"), "templates/pandoc_skeleton.html")
  css_template = joinpath(Pkg.dir("Weave"), "templates/pandoc_skeleton.css")

  path, wsource = splitdir(abspath(doc.source))
  wversion = string(Pkg.installed("Weave"))
  wtime =  Date(now())

  outname = "$(doc.basename).html"

  #Change path for pandoc
  old_wd = pwd()
  cd(doc.cwd)
  html =""

  try
  #html = @compat readstring(
  run(pipeline(`echo $formatted` ,
   `pandoc -R -s --mathjax="" --self-contained --highlight-style=tango
   --template $html_template --include-in-header=$css_template
    -V wversion=$wversion -V wtime=$wtime -V wsource=$wsource
    -o $outname`))
  #  )
    cd(old_wd)
  catch
    cd(old_wd)
    error("Unable to convert to html, check that you have pandoc installed and in your path")
  end
end

"""
`pandoc2pdf(formatted::AbstractString, doc::WeaveDoc)`

Convert output from pandoc markdown to pdf using Weave.jl template
"""
function pandoc2pdf(formatted::AbstractString, doc::WeaveDoc)

  header_template = joinpath(Pkg.dir("Weave"), "templates/pandoc_header.txt")

  path, wsource = splitdir(abspath(doc.source))
  wversion = string(Pkg.installed("Weave"))
  wtime =  Date(now())

  outname = "$(doc.basename).pdf"

  #Change path for pandoc
  old_wd = pwd()
  cd(doc.cwd)
  html =""

  info("Done executing code. Running xelatex")
  try
    run(pipeline(`echo $formatted` ,
     `pandoc -R -s  --latex-engine=xelatex --highlight-style=tango
      --include-in-header=$header_template
      -V fontsize=12pt
      -o $outname`))

  #run(pipeline(`echo $formatted` ,
  # `pandoc -R -s --mathjax --self-contained --template
  #  $html_template  -V wversion=$wversion -V wtime=$wtime -V wsource=$wsource
  #  -o $outname`))

    cd(old_wd)
  catch
    cd(old_wd)
    error("Unable to convert to html, check that you have pandoc installed and in your path")
  end
end
