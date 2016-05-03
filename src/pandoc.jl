

"""
`pandoc2html(formatted::AbstractString, doc::WeaveDoc)`

Convert output from pandoc markdown to html using Weave.jl template
"""
function pandoc2html(formatted::AbstractString, doc::WeaveDoc, outname::AbstractString)
  html_template = joinpath(Pkg.dir("Weave"), "templates/pandoc_skeleton.html")
  css_template = joinpath(Pkg.dir("Weave"), "templates/pandoc_skeleton.css")

  path, wsource = splitdir(abspath(doc.source))
  wversion = string(Pkg.installed("Weave"))
  wtime =  string(Date(now()))

  #Change path for pandoc
  old_wd = pwd()
  cd(doc.cwd)
  html =""
  outname = basename(outname)

  try
    pandoc_out, pandoc_in, proc = readandwrite(`pandoc -R -s --mathjax="" --self-contained --highlight-style=tango
    --template $html_template -c $css_template
     -V wversion=$wversion -V wtime=$wtime -V wsource=$wsource
     -o $outname`)
    println(pandoc_in, formatted)

    close(pandoc_in)
    proc_output = readall(pandoc_out)
    cd(old_wd)
  catch e
    cd(old_wd)
    warn("Error converting document to HTML")
    throw(e)
  end
end

"""
`pandoc2pdf(formatted::AbstractString, doc::WeaveDoc)`

Convert output from pandoc markdown to pdf using Weave.jl template
"""
function pandoc2pdf(formatted::AbstractString, doc::WeaveDoc, outname::AbstractString)

  header_template = joinpath(Pkg.dir("Weave"), "templates/pandoc_header.txt")

  path, wsource = splitdir(abspath(doc.source))
  wversion = string(Pkg.installed("Weave"))
  wtime =  Date(now())
  outname = basename(outname)

  #Change path for pandoc
  old_wd = pwd()
  cd(doc.cwd)
  html =""

  info("Done executing code. Running xelatex")
  try
    pandoc_out, pandoc_in, proc = readandwrite(`pandoc -R -s  --latex-engine=xelatex --highlight-style=tango
     --include-in-header=$header_template
     -V fontsize=12pt -o $outname`) 
    println(pandoc_in, formatted)

    close(pandoc_in)
    proc_output = readall(pandoc_out)
    cd(old_wd)
  catch e
    cd(old_wd)
    warn("Error converting document to pdf")
    throw(e)
  end
end
