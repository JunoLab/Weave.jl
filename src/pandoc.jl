function pandoc2html(formatted, doc, highlight_theme, outname, pandoc_options)
    template_path = normpath(PKG_DIR, "templates/pandoc_skeleton.html")
    themecss_path = normpath(PKG_DIR, "templates/pandoc_skeleton.css")
    highlightcss = get_highlight_stylesheet(MIME("text/html"), highlight_theme)

    path, wsource = splitdir(abspath(doc.source))
    wversion, wdate = weave_info()

    # Header is inserted from displayed plots
    header_script = doc.header_script
    self_contained = (header_script ≠ "") ? [] : "--self-contained"

    if haskey(doc.header, "bibliography")
        filt = "--filter"
        citeproc = "pandoc-citeproc"
    else
        filt = []
        citeproc = []
    end

    # Change path for pandoc
    cd_back = let d = pwd(); () -> cd(d); end
    cd(doc.cwd)
    outname = basename(outname)

    try
        cmd = `pandoc -f markdown+raw_html -s --mathjax=""
        $filt $citeproc $pandoc_options
        --template $template_path
        -H $themecss_path
        $self_contained
         -V wversion=$wversion
         -V wdate=$wdate
         -V wsource=$wsource
         -V highlightcss=$highlightcss
         -V headerscript=$header_script
         -o $outname`
        proc = open(cmd, "r+")
        println(proc.in, formatted)
        close(proc.in)
        proc_output = read(proc.out, String)
    catch
        @warn "Error converting document to HTML"
        rethrow() # TODO: just show error content instead of rethrow the err
    finally
        cd_back()
    end
end

function pandoc2pdf(formatted, doc, outname, pandoc_options)
    weavedir = dirname(@__FILE__)
    header_template = joinpath(weavedir, "../templates/pandoc_header.txt")

    path, wsource = splitdir(abspath(doc.source))
    outname = basename(outname)

    # Change path for pandoc
    cd_back = let d = pwd(); () -> cd(d); end
    cd(doc.cwd)

    if haskey(doc.header, "bibliography")
        filt = "--filter"
        citeproc = "pandoc-citeproc"
    else
        filt = []
        citeproc = []
    end

    @info "Done executing code. Running xelatex"
    try
        cmd = `pandoc -f markdown+raw_tex -s  --pdf-engine=xelatex --highlight-style=tango
         $filt $citeproc $pandoc_options
         --include-in-header=$header_template
         -V fontsize=12pt -o $outname`
        proc = open(cmd, "r+")
        println(proc.in, formatted)
        close(proc.in)
        proc_output = read(proc.out, String)
    catch
        @warn "Error converting document to pdf"
        rethrow()
    finally
        cd_back()
    end
end

function run_latex(doc::WeaveDoc, outname, latex_cmd = "xelatex")
    cd_back = let d = pwd(); () -> cd(d); end
    cd(doc.cwd)

    xname = basename(outname)
    @info "Weaved code to $outname . Running $latex_cmd" # space before '.' added for link to be clickable in Juno terminal
    textmp = mktempdir(".")
    try
        cmd = `$latex_cmd -shell-escape $xname -aux-directory $textmp -include-directory $(doc.cwd)`
        run(cmd); run(cmd) # XXX: is twice enough for every case ?
    catch
        @warn "Error converting document to pdf. Try running latex manually"
        rethrow()
    finally
        rm(xname)
        rm(textmp, recursive = true)
        cd_back()
    end
end
