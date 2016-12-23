

"""
`pandoc2html(formatted::AbstractString, doc::WeaveDoc)`

Convert output from pandoc markdown to html using Weave.jl template
"""
function pandoc2html(formatted::AbstractString, doc::WeaveDoc, outname::AbstractString)
  weavedir = dirname(@__FILE__)
  html_template = joinpath(weavedir, "../templates/pandoc_skeleton.html")
  css_template = joinpath(weavedir, "../templates/pandoc_skeleton.css")

  path, wsource = splitdir(abspath(doc.source))
  wversion = string(Pkg.installed("Weave"))
  wtime =  string(Date(now()))

  #Header is inserted from displayed plots
  header_script = doc.header_script
  #info(doc.header_script)

  if header_script ≠ ""
    self_contained = []
  else
    self_contained = "--self-contained"
  end

  #Change path for pandoc
  old_wd = pwd()
  cd(doc.cwd)
  html =""
  outname = basename(outname)

  try
    pandoc_out, pandoc_in, proc = readandwrite(`pandoc -R -s --mathjax="" --highlight-style=tango
    --template $html_template -H $css_template $self_contained
     -V wversion=$wversion -V wtime=$wtime -V wsource=$wsource
     -V headerscript=$header_script
     -o $outname`)
    println(pandoc_in, formatted)

    close(pandoc_in)
    proc_output = readstring(pandoc_out)
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
  weavedir = dirname(@__FILE__)
  header_template = joinpath(weavedir, "../templates/pandoc_header.txt")

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

function run_latex(doc::WeaveDoc, outname, latex_cmd = "pdflatex")
  old_wd = pwd()
  cd(doc.cwd)
  xname = basename(outname)
  info("Weaved code to $outname. Running $latex_cmd")
  try
    textmp = mktempdir(".")
    out = readstring(`$latex_cmd --output-directory=$textmp $xname`)
    pdf = joinpath(textmp, "$(doc.basename).pdf")
    cp(pdf, "$(doc.basename).pdf", remove_destination=true)
    rm(textmp, recursive=true)
    rm(xname)
    cd(old_wd)
    rm(doc.fig_path, force = true, recursive = true)
    return true
  catch e
    cd(old_wd)
    warn("Error converting document to pdf. Try running latex manually")
    return false
    #throw(e)
  end
end
