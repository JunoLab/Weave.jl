using Base64


const PROGRESS_ID = "weave_progress"

function run_doc(
    doc::WeaveDoc;
    doctype::Union{Nothing,AbstractString} = nothing,
    out_path::Union{Symbol,AbstractString} = :doc,
    args::Dict = Dict(),
    mod::Union{Module,Nothing} = nothing,
    fig_path::Union{Nothing,AbstractString} = nothing,
    fig_ext::Union{Nothing,AbstractString} = nothing,
    cache_path::AbstractString = "cache",
    cache::Symbol = :off,
    throw_errors::Bool = false,
)
    # cache :all, :user, :off, :refresh

    doc.doctype = isnothing(doctype) ? (doctype = detect_doctype(doc.source)) : doctype
    doc.format = deepcopy(FORMATS[doctype])

    cwd = doc.cwd = get_cwd(doc, out_path)
    isdir(cwd) || mkpath(cwd)

    if isnothing(fig_path)
        fig_path = if (endswith(doctype, "2pdf") && cache === :off) || endswith(doctype, "2html")
            basename(mktempdir(abspath(doc.cwd)))
        else
            DEFAULT_FIG_PATH
        end
    end
    let d = normpath(cwd, fig_path); isdir(d) || mkdir(d); end
    # This is needed for latex and should work on all output formats
    @static Sys.iswindows() && (fig_path = replace(fig_path, "\\" => "/"))
    set_rc_params(doc, fig_path, fig_ext)

    cache === :off || @eval import Serialization # XXX: evaluate in a more sensible module

    # New sandbox for each document with args exposed
    isnothing(mod) && (mod = sandbox = Core.eval(Main, :(module $(gensym(:WeaveSandBox)) end))::Module)
    @eval mod WEAVE_ARGS = $args

    mimetypes = doc.format.mimetypes

    report = Report(doc.cwd, doc.basename, doc.format, mimetypes, throw_errors)
    pushdisplay(report)
    try
        if cache !== :off && cache !== :refresh
            cached = read_cache(doc, cache_path)
            isnothing(cached) && @info "No cached results found, running code"
        else
            cached = nothing
        end

        executed = []
        n = length(filter(chunk->isa(chunk,CodeChunk), doc.chunks))
        i = 0
        for chunk in doc.chunks
            if chunk isa CodeChunk
                options = merge(doc.chunk_defaults, chunk.options)
                merge!(chunk.options, options)

                @info "Weaving chunk $(chunk.number) from line $(chunk.start_line)" progress=(i)/n _id=PROGRESS_ID
                i+=1
            end

            restore = (cache === :user && chunk isa CodeChunk && chunk.options[:cache])
            result_chunks = if cached ≠ nothing && (cache === :all || restore)
                restore_chunk(chunk, cached)
            else
                run_chunk(chunk, doc, report, mod)
            end
            executed = [executed; result_chunks]
        end

        replace_header_inline!(doc, report, mod) # evaluate and replace inline code in header

        doc.header_script = report.header_script
        doc.chunks = executed

        cache !== :off && write_cache(doc, cache_path)

        @isdefined(sandbox) && clear_module!(sandbox)
    catch err
        rethrow(err)
    finally
        @info "Weaved all chunks" progress=1 _id=PROGRESS_ID
        popdisplay(report) # ensure display pops out even if internal error occurs
    end

    return doc
end

run_doc(doc::WeaveDoc, doctype::Union{Nothing,AbstractString}; kwargs...) =
    run_doc(doc; doctype = doctype, kwargs...)

"""
    detect_doctype(path)

Detect the output format based on file extension.
"""
function detect_doctype(path)
    _, ext = lowercase.(splitext(path))

    match(r"^\.(jl|.?md|ipynb)", ext) !== nothing && return "md2html"
    ext == ".rst" && return "rst"
    ext == ".tex" && return "texminted"
    ext == ".txt" && return "asciidoc"

    return "pandoc"
end

function run_chunk(chunk::CodeChunk, doc, report, mod)
    result = eval_chunk(doc, chunk, report, mod)
    occursin("2html", doc.doctype) && (embed_figures!(result, report.cwd))
    return result
end

function embed_figures!(chunk::CodeChunk, cwd)
    for (i, fig) in enumerate(chunk.figures)
        chunk.figures[i] = img2base64(fig, cwd)
    end
end

function embed_figures!(chunks::Vector{CodeChunk}, cwd)
    for chunk in chunks
        embed_figures!(chunk, cwd)
    end
end

function img2base64(fig, cwd)
    ext = splitext(fig)[2]
    f = open(joinpath(cwd, fig), "r")
    raw = read(f)
    close(f)
    if ext == ".png"
        return "data:image/png;base64," * stringmime(MIME("image/png"), raw)
    elseif ext == ".svg"
        return "data:image/svg+xml;base64," * stringmime(MIME("image/svg"), raw)
    elseif ext == ".gif"
        return "data:image/gif;base64," * stringmime(MIME("image/gif"), raw)
    else
        return (fig)
    end
end

function run_chunk(chunk::DocChunk, doc, report, mod)
    chunk.content = [run_inline(c, doc, report, mod) for c in chunk.content]
    return chunk
end

run_inline(inline::InlineText, ::WeaveDoc, ::Report, ::Module) = inline

const INLINE_OPTIONS = Dict(
    :term => false,
    :hold => true,
    :wrap => false
)

function run_inline(inline::InlineCode, doc::WeaveDoc, report::Report, mod::Module)
    # Make a temporary CodeChunk for running code. Collect results and don't wrap
    chunk = CodeChunk(inline.content, 0, 0, "", INLINE_OPTIONS)
    options = merge(doc.chunk_defaults, chunk.options)
    merge!(chunk.options, options)

    chunks = eval_chunk(doc, chunk, report, mod)
    occursin("2html", doc.doctype) && (embed_figures!(chunks, report.cwd))

    output = chunks[1].output
    endswith(output, "\n") && (output = output[1:end-1])
    inline.output = output
    inline.rich_output = chunks[1].rich_output
    inline.figures = chunks[1].figures
    return inline
end

function reset_report(report::Report)
    report.cur_result = ""
    report.figures = AbstractString[]
    report.term_state = :text
end

function run_code(doc::WeaveDoc, chunk::CodeChunk, report::Report, mod::Module)
    ss = parse_input(chunk.content)
    n = length(ss)
    results = ChunkOutput[]
    for (i, s) in enumerate(ss)
        reset_report(report)
        obj, out = capture_output(
            mod,
            s,
            doc.path,
            chunk.options[:term],
            chunk.options[:display],
            i == n,
            report.throw_errors,
        )
        figures = report.figures # Captured figures
        result = ChunkOutput(s, out, report.cur_result, report.rich_output, figures)
        report.rich_output = ""
        push!(results, result)
    end
    return results
end

# Parse chunk input to array of expressions
function parse_input(s)
    res = String[]
    s = lstrip(s)
    n = sizeof(s)
    pos = 1
    while (oldpos = pos) ≤ n
        _, pos = Meta.parse(s, pos)
        push!(res, s[oldpos:pos-1])
    end
    return res
end

function capture_output(mod, s, path, term, disp, lastline, throw_errors = false)
    local out = nothing
    local obj = nothing

    old = stdout
    rw, wr = redirect_stdout()
    reader = @async read(rw, String)

    task_local_storage(:SOURCE_PATH, path) do
        try
            obj = include_string(mod, s, path) # TODO: fix line number
            !isnothing(obj) && ((term || disp) || lastline) && display(obj)
        catch _err
            err = unwrap_load_err(_err)
            throw_errors && throw(err)
            display(err)
            @warn "ERROR: $(typeof(err)) occurred, including output in Weaved document"
        finally
            redirect_stdout(old)
            close(wr)
            out = fetch(reader)
            close(rw)
        end
    end

    out = replace(out, r"\u001b\[.*?m" => "") # remove ANSI color codes
    return (obj, out)
end

unwrap_load_err(err) = return err
unwrap_load_err(err::LoadError) = return err.error

function eval_chunk(doc::WeaveDoc, chunk::CodeChunk, report::Report, mod::Module)
    if !chunk.options[:eval]
        chunk.output = ""
        chunk.options[:fig] = false
        return chunk
    end

    # Run preexecute_hooks
    for hook in preexecute_hooks
        chunk = Base.invokelatest(hook, chunk)
    end

    report.fignum = 1
    report.cur_chunk = chunk

    if hasproperty(report.format, :out_width) && isnothing(chunk.options[:out_width])
        chunk.options[:out_width] = report.format.out_width
    end

    chunk.result = run_code(doc, chunk, report, mod)

    # Run post_execute chunks
    for hook in postexecute_hooks
        chunk = Base.invokelatest(hook, chunk)
    end

    chunks = if chunk.options[:term]
        collect_term_results(chunk)
    elseif chunk.options[:hold]
        collect_hold_results(chunk)
    else
        collect_results(chunk)
    end

    # else
    #   chunk.options[:fig] && (chunk.figures = copy(report.figures))
    # end

    return chunks
end

"""
    clear_module!(mod::Module)

Recursively sets variables in `mod` to `nothing` so that they're GCed.

!!! warning
    `const` variables can't be reassigned, as such they can't be cleared.
"""
function clear_module!(mod::Module)
    for name in names(mod; all = true)
        name === :eval && continue
        try
            v = getfield(mod, name)
            if v isa Module && v != mod
                clear_module!(v)
                continue
            end
            isconst(mod, name) && continue # can't clear constant
            Core.eval(mod, :($name = nothing))
        catch err
            @debug err
        end
    end
end

function get_figname(report::Report, chunk; fignum = nothing, ext = nothing)
    isnothing(ext) && (ext = chunk.options[:fig_ext])
    isnothing(fignum) && (fignum = report.fignum)

    chunkid = isnothing(chunk.options[:label]) ? chunk.number : chunk.options[:label]
    basename = string(report.basename, '_', chunkid, '_', fignum, ext)
    full_name = normpath(report.cwd, chunk.options[:fig_path], basename)
    rel_name = string(chunk.options[:fig_path], '/', basename) # Relative path is used in output
    return full_name, rel_name
end

function get_cwd(doc::WeaveDoc, out_path)
    # Set the output directory
    if out_path === :doc
        cwd = dirname(doc.path)
    elseif out_path === :pwd
        cwd = pwd()
    else
        # If there is no extension, use as path
        splitted = splitext(out_path)
        if splitted[2] == ""
            cwd = expanduser(out_path)
        else
            cwd = splitdir(expanduser(out_path))[1]
        end
    end
    return cwd
end

"""Get output file name based on out_path"""
function get_outname(out_path::Symbol, doc::WeaveDoc; ext = nothing)
    isnothing(ext) && (ext = doc.format.extension)
    outname = "$(doc.cwd)/$(doc.basename).$ext"
end

"""Get output file name based on out_path"""
function get_outname(out_path::AbstractString, doc::WeaveDoc; ext = nothing)
    isnothing(ext) && (ext = doc.format.extension)
    splitted = splitext(out_path)
    if (splitted[2]) == ""
        outname = "$(doc.cwd)/$(doc.basename).$ext"
    else
        outname = expanduser(out_path)
    end
end

function set_rc_params(doc::WeaveDoc, fig_path, fig_ext)
    if isnothing(fig_ext)
        doc.chunk_defaults[:fig_ext] = doc.format.fig_ext
    else
        doc.chunk_defaults[:fig_ext] = fig_ext
    end
    doc.chunk_defaults[:fig_path] = fig_path
end

function collect_results(chunk::CodeChunk)
    content = ""
    result_chunks = CodeChunk[]
    for r in chunk.result
        # Check if there is any output from chunk
        if strip(r.stdout) == "" && isempty(r.figures) && strip(r.rich_output) == ""
            content *= r.code
        else
            content = "\n" * content * r.code
            rchunk = CodeChunk(
                content,
                chunk.number,
                chunk.start_line,
                chunk.optionstring,
                copy(chunk.options),
            )
            content = ""
            rchunk.figures = r.figures
            rchunk.output = r.stdout * r.displayed
            rchunk.rich_output = r.rich_output
            push!(result_chunks, rchunk)
        end
    end
    if !isempty(content)
        startswith(content, "\n") || (content = "\n" * content)
        rchunk = CodeChunk(
            content,
            chunk.number,
            chunk.start_line,
            chunk.optionstring,
            copy(chunk.options),
        )
        push!(result_chunks, rchunk)
    end

    return result_chunks
end

function collect_term_results(chunk::CodeChunk)
    output = ""
    prompt = chunk.options[:prompt]
    result_chunks = CodeChunk[]
    for r in chunk.result
        output *= prompt * r.code
        output *= r.displayed * r.stdout
        if !isempty(r.figures)
            rchunk = CodeChunk(
                "",
                chunk.number,
                chunk.start_line,
                chunk.optionstring,
                copy(chunk.options),
            )
            rchunk.output = output
            output = ""
            rchunk.figures = r.figures
            push!(result_chunks, rchunk)
        end
    end
    if !isempty(output)
        rchunk = CodeChunk(
            "",
            chunk.number,
            chunk.start_line,
            chunk.optionstring,
            copy(chunk.options),
        )
        rchunk.output = output
        push!(result_chunks, rchunk)
    end

    return result_chunks
end

function collect_hold_results(chunk::CodeChunk)
    for r in chunk.result
        chunk.output *= r.stdout
        chunk.rich_output *= r.rich_output
        chunk.figures = [chunk.figures; r.figures]
    end
    return [chunk]
end

const HEADER_INLINE = Regex("$(HEADER_INLINE_START)(?<code>.+)$(HEADER_INLINE_END)")

replace_header_inline!(doc, report, mod) = _replace_header_inline!(doc, doc.header, report, mod)

function _replace_header_inline!(doc, header, report, mod)
    replace!(header) do (k,v)
        return k =>
            v isa Dict ? _replace_header_inline!(doc, v, report, mod) :
            !isa(v, AbstractString) ? v :
            replace(v, HEADER_INLINE => s -> begin
                code = replace(s, HEADER_INLINE => s"\g<code>")
                run_inline_code(code, doc, report, mod)
            end)
    end
    return header
end

function run_inline_code(code, doc, report, mod)
    inline = InlineCode(code, 1, :inline)
    inline = run_inline(inline, doc, report, mod)
    return strip(inline.output, '"')
end
