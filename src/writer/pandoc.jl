function write_doc(docformat::Pandoc2HTML, doc, rendered, out_path)
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

    out_path = get_out_path(doc, out_path, "html")
    cd_back = let d = pwd(); () -> cd(d); end
    cd(dirname(out_path))
    try
        out = basename(out_path)
        highlight_stylesheet = get_highlight_stylesheet(MIME("text/html"), docformat.highlight_theme)
        cmd = `pandoc -f markdown+raw_html -s --mathjax=""
        $filt $citeproc $(docformat.pandoc_options)
        --template $(docformat.template_path)
        -H $(docformat.stylesheet_path)
        $(self_contained)
        -V highlight_stylesheet=$(highlight_stylesheet)
        -V weave_version=$(weave_version)
        -V weave_date=$(weave_date)
        -V weave_source=$(weave_source)
        -V headerscript=$(header_script)
        -o $(out)`
        proc = open(cmd, "r+")
        println(proc.in, rendered)
        close(proc.in)
        proc_output = read(proc.out, String)
    catch
        rethrow() # TODO: just show error content instead of rethrow the err
    finally
        cd_back()
    end

    return out_path
end

function write_doc(docformat::Pandoc2PDF, doc, rendered, out_path)
    if haskey(doc.header, "bibliography")
        filt = "--filter"
        citeproc = "pandoc-citeproc"
    else
        filt = []
        citeproc = []
    end

    out_path = get_out_path(doc, out_path, "pdf")
    cd_back = let d = pwd(); () -> cd(d); end
    cd(dirname(out_path))
    try
        out = basename(out_path)
        cmd = `pandoc -f markdown+raw_tex -s  --pdf-engine=xelatex --highlight-style=tango
         $filt $citeproc $(docformat.pandoc_options)
         --include-in-header=$(docformat.header_template)
         -o $(out)`
        proc = open(cmd, "r+")
        println(proc.in, rendered)
        close(proc.in)
        proc_output = read(proc.out, String)
    catch
        rethrow()
    finally
        cd_back()
    end

    return out_path
end
