

"""
`pandoc2html(formatted::AbstractString, doc::WeaveDoc)`

Convert output from pandoc markdown to html using Weave.jl template
"""
function pandoc2html(formatted::AbstractString, doc::WeaveDoc, outname::AbstractString, pandoc_options)
  weavedir = dirname(@__FILE__)
  html_template = joinpath(weavedir, "../templates/pandoc_skeleton.html")
  css_template = joinpath(weavedir, "../templates/pandoc_skeleton.css")
  css = stylesheet(MIME("text/html"), doc.highlight_theme)

  path, wsource = splitdir(abspath(doc.source))
  #wversion = string(Pkg.installed("Weave"))
  wversion = ""
  wtime =  string(Date(now()))

  #Header is inserted from displayed plots
  header_script = doc.header_script
  self_contained = (header_script ≠ "") ? [] : "--self-contained"

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

  open("temp.md", "w") do io
    println(io, formatted)
  end

  try
    cmd = `pandoc -f markdown+raw_html -s --mathjax=""
    $filt $citeproc $pandoc_options
    --template $html_template -H $css_template $self_contained
     -V wversion=$wversion -V wtime=$wtime -V wsource=$wsource
     -V highlightcss=$css
     -V headerscript=$header_script
     -o $outname`
     proc = open(cmd, "r+")
     println(proc.in, formatted)
     close(proc.in)
     proc_output = read(proc.out, String)
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
function pandoc2pdf(formatted::AbstractString, doc::WeaveDoc, outname::AbstractString, pandoc_options)
  weavedir = dirname(@__FILE__)
  header_template = joinpath(weavedir, "../templates/pandoc_header.txt")

  path, wsource = splitdir(abspath(doc.source))
  #wversion = string(Pkg.installed("Weave"))
  wversion = ""
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
    cmd = `pandoc -f markdown+raw_tex -s  --pdf-engine=xelatex --highlight-style=tango
     $filt $citeproc $pandoc_options
     --include-in-header=$header_template
     -V fontsize=12pt -o $outname`
    proc = open(cmd, "r+")
    println(proc.in, formatted)
    close(proc.in)
    proc_output = read(proc.out, String)
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
  @info("Weaved code to $outname . Running $latex_cmd") # space before '.' added for link to be clickable in Juno terminal
  textmp = mktempdir(".")
  try
    out = read(`$latex_cmd -shell-escape $xname -aux-directory $textmp -include-directory $(doc.cwd)`, String)
    out = read(`$latex_cmd -shell-escape $xname -aux-directory $textmp -include-directory $(doc.cwd)`, String)
    rm(xname)
    rm(textmp, recursive=true)
    cd(old_wd)
    return true
  catch e
    @warn("Error converting document to pdf. Try running latex manually")
    cd(old_wd)
    rm(textmp)
    return false
  end
end
