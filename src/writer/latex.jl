function write_doc(docformat::WeaveLaTeX2PDF, doc, rendered, out_path)
    cd_back = let d = pwd(); () -> cd(d); end
    cd(doc.cwd)
    try
        tex_path = basename(out_path)
        write(tex_path, rendered)
        cmds = copy(docformat.latex_cmd)
        push!(cmds, tex_path)
        cmd = Cmd(cmds)
        run(cmd); run(cmd) # XXX: is twice enough for every case ?
    catch
        @warn "Error converting document to pdf. Try running latex manually"
        rethrow()
    finally
        cd_back()
    end

    return get_out_path(doc, out_path, "pdf")
end
