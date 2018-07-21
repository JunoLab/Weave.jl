

"""
`pandoc2html(formatted::AbstractString, doc::WeaveDoc)`

Convert output from pandoc markdown to html using Weave.jl template
"""
function pandoc2html(formatted::AbstractString, doc::WeaveDoc, outname::AbstractString)
  weavedir = dirname(@__FILE__)
  html_template = joinpath(weavedir, "../templates/pandoc_skeleton.html")
  css_template = joinpath(weavedir, "../templates/pandoc_skeleton.css")
  css = stylesheet(MIME("text/html"), doc.highlight_theme)

  path, wsource = splitdir(abspath(doc.source))
  wversion = string(Pkg.installed("Weave"))
  wtime =  string(Date(now()))

  #Header is inserted from displayed plots
  header_script = doc.header_script

  if header_script ≠ ""
    self_contained = []
  else
    self_contained = "--self-contained"
  end

  if haskey(doc.header, "bibliography")
    filt = "--filter"
    citeproc = "pandoc-citeproc"
  else
    filt = []
    citeproc = []
  end

  #Change path for pandoc
  old_wd = pwd()
  cd(doc.cwd)
  html =""
  outname = basename(outname)

  try
    pandoc_out, pandoc_in, proc = readandwrite(`pandoc -R -s --mathjax="" 
    $filt $citeproc
    --template $html_template -H $css_template $self_contained
     -V wversion=$wversion -V wtime=$wtime -V wsource=$wsource
     -V highlightcss=$css
     -V headerscript=$header_script
     -o $outname`)
    println(pandoc_in, formatted)
    close(pandoc_in)
    proc_output = read(pandoc_out, String)
    cd(old_wd)
  catch e
    cd(old_wd)
    @warn("Error converting document to HTML")
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

  if haskey(doc.header, "bibliography")
    filt = "--filter"
    citeproc = "pandoc-citeproc"
  else
    filt = []
    citeproc = []
  end

  @info("Done executing code. Running xelatex")
  try
    pandoc_out, pandoc_in, proc = readandwrite(`pandoc -R -s  --latex-engine=xelatex --highlight-style=tango
     $filt $citeproc
     --include-in-header=$header_template
     -V fontsize=12pt -o $outname`)
    println(pandoc_in, formatted)

    close(pandoc_in)
    proc_output = read(pandoc_out, String)
    cd(old_wd)
  catch e
    cd(old_wd)
    @warn("Error converting document to pdf")
    throw(e)
  end
end

function run_latex(doc::WeaveDoc, outname, latex_cmd = "xelatex")
  old_wd = pwd()
  cd(doc.cwd)
  xname = basename(outname)
  info("Weaved code to $outname. Running $latex_cmd")
  try
    textmp = mktempdir(".")
    #out = readstring(`$latex_cmd -shell-escape --output-directory=$textmp $xname`)
    out = read(`$latex_cmd -shell-escape $xname`, String)
    #info(out)
    #pdf = joinpath(textmp, "$(doc.basename).pdf")
    #cp(pdf, "$(doc.basename).pdf", remove_destination=true)
    #rm(textmp, recursive=true)
    rm(xname)
    cd(old_wd)
    return true
  catch e
    cd(old_wd)
    @warn("Error converting document to pdf. Try running latex manually")
    return false
    #throw(e)
  end
end
