function pandoc2html(rendered, doc, highlight_theme, out_path, pandoc_options)
    template_path = normpath(TEMPLATE_DIR, "pandoc2html.html")
    stylesheet_path = normpath(STYLESHEET_DIR, "pandoc2html_skeleton.css")
    highlight_stylesheet = get_highlight_stylesheet(MIME("text/html"), highlight_theme)

    _, weave_source = splitdir(abspath(doc.source))
    weave_version, weave_date = weave_info()

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
    out_path = basename(out_path)

    try
        cmd = `pandoc -f markdown+raw_html -s --mathjax=""
        $filt $citeproc $pandoc_options
        --template $template_path
        -H $stylesheet_path
        $self_contained
        -V highlight_stylesheet=$highlight_stylesheet
        -V weave_version=$weave_version
        -V weave_date=$weave_date
        -V weave_source=$weave_source
        -V headerscript=$header_script
        -o $out_path`
        proc = open(cmd, "r+")
        println(proc.in, rendered)
        close(proc.in)
        proc_output = read(proc.out, String)
    catch
        @warn "Error converting document to HTML"
        rethrow() # TODO: just show error content instead of rethrow the err
    finally
        cd_back()
    end
end

function pandoc2pdf(rendered, doc, out_path, pandoc_options)
    header_template = normpath(TEMPLATE_DIR, "pandoc2pdf_header.txt")

    out_path = basename(out_path)

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
         -V fontsize=12pt -o $out_path`
        proc = open(cmd, "r+")
        println(proc.in, rendered)
        close(proc.in)
        proc_output = read(proc.out, String)
    catch
        @warn "Error converting document to pdf"
        rethrow()
    finally
        cd_back()
    end
end

function run_latex(doc::WeaveDoc, out_path, latex_cmd = "xelatex")
    cd_back = let d = pwd(); () -> cd(d); end
    cd(doc.cwd)

    xname = basename(out_path)
    @info "Weaved code to $out_path . Running $latex_cmd" # space before '.' added for link to be clickable in Juno terminal
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
