using Base64


const PROGRESS_ID = "weave_progress"

function run_doc(
    doc::WeaveDoc;
    doctype::Union{Nothing,AbstractString} = nothing,
    out_path::Union{Symbol,AbstractString} = :doc,
    args::Any = Dict(),
    mod::Union{Module,Nothing} = nothing,
    fig_path::Union{Nothing,AbstractString} = nothing,
    fig_ext::Union{Nothing,AbstractString} = nothing,
    cache_path::AbstractString = "cache",
    cache::Symbol = :off,
)
    # cache :all, :user, :off, :refresh

    doc.doctype = isnothing(doctype) ? (doctype = detect_doctype(doc.source)) : doctype
    doc.format = deepcopy(get_format(doctype))

    cwd = doc.cwd = get_cwd(doc, out_path)
    mkpath(cwd)

    # TODO: provide a way not to create `fig_path` ?
    if isnothing(fig_path)
        fig_path = if (endswith(doctype, "2pdf") && cache === :off) || endswith(doctype, "2html")
            basename(mktempdir(abspath(cwd)))
        else
            DEFAULT_FIG_PATH
        end
    end
    mkpath(normpath(cwd, fig_path))
    # This is needed for latex and should work on all output formats
    @static Sys.iswindows() && (fig_path = replace(fig_path, "\\" => "/"))
    set_rc_params(doc, fig_path, fig_ext)

    cache === :off || @eval import Serialization # XXX: evaluate in a more sensible module

    # New sandbox for each document with args exposed
    isnothing(mod) && (mod = sandbox = Core.eval(Main, :(module $(gensym(:WeaveSandBox)) end))::Module)
    Core.eval(mod, :(WEAVE_ARGS = $(args)))

    mimetypes = doc.format.mimetypes

    report = Report(cwd, doc.basename, doc.format, mimetypes)
    cd_back = let d = pwd(); () -> cd(d); end
    cd(cwd)
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
        cd_back()
        popdisplay(report) # ensure display pops out even if internal error occurs
        # Temporary fig_path is not automatically removed because it contains files so...
        !isnothing(fig_path) && startswith(fig_path, "jl_") && rm(normpath(cwd, fig_path), force=true, recursive=true)
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

function get_cwd(doc, out_path)
    return if out_path === :doc
        dirname(doc.path)
    elseif out_path === :pwd
        pwd()
    else
        path, ext = splitext(out_path)
        if isempty(ext) # directory given
            path
        else # file given
            dirname(path)
        end
    end |> abspath
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
embed_figures!(chunks, cwd) = embed_figures!.(chunks, Ref(cwd))

function img2base64(fig, cwd)
    ext = splitext(fig)[2]
    f = open(joinpath(cwd, fig), "r")
    raw = read(f)
    close(f)
    return ext == ".png" ? "data:image/png;base64," * stringmime(MIME("image/png"), raw) :
           ext == ".svg" ? "data:image/svg+xml;base64," * stringmime(MIME("image/svg"), raw) :
           ext == ".gif" ? "data:image/gif;base64," * stringmime(MIME("image/gif"), raw) :
           fig
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

function run_code(doc::WeaveDoc, chunk::CodeChunk, report::Report, mod::Module)
    code = chunk.content
    path = doc.path
    error = chunk.options[:error]
    codes = chunk.options[:term] ? split_code(code) : [code]
    capture = code -> capture_output(code, mod, path, error, report)
    return capture.(codes)
end

function split_code(code)
    res = String[]
    e = 1
    ex = :init
    while true
        s = e
        ex, e = Meta.parse(code, s)
        isnothing(ex) && break
        push!(res, strip(code[s:e-1]))
    end
    return res
end

function capture_output(code, mod, path, error, report)
    reset_report!(report)

    old = stdout
    rw, wr = redirect_stdout()
    reader = @async read(rw, String)

    local out = nothing
    task_local_storage(:SOURCE_PATH, path) do
        try
            obj = include_string(mod, code, path) # TODO: fix line number
            !isnothing(obj) && !REPL.ends_with_semicolon(code) && display(obj)
        catch _err
            err = unwrap_load_err(_err)
            error || throw(err)
            display(err)
            @warn "ERROR: $(typeof(err)) occurred, including output in Weaved document"
        finally
            redirect_stdout(old)
            close(wr)
            out = fetch(reader)
            close(rw)
        end
    end

    return ChunkOutput(code, remove_ansi_control_chars(out), report.rich_output, report.figures)
end

function reset_report!(report)
    report.rich_output = ""
    report.figures = String[]
end

unwrap_load_err(err) = return err
unwrap_load_err(err::LoadError) = return err.error

# https://stackoverflow.com/a/33925425/12113178
remove_ansi_control_chars(s) = replace(s, r"(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]" => "")

function eval_chunk(doc::WeaveDoc, chunk::CodeChunk, report::Report, mod::Module)
    if !chunk.options[:eval]
        chunk.output = ""
        chunk.options[:fig] = false
        return chunk
    end

    execute_prehooks!(chunk)

    report.cur_chunk = chunk

    if hasproperty(report.format, :out_width) && isnothing(chunk.options[:out_width])
        chunk.options[:out_width] = report.format.out_width
    end

    chunk.result = run_code(doc, chunk, report, mod)

    execute_posthooks!(chunk)

    return chunk.options[:term] ? collect_term_results(chunk) :
           chunk.options[:hold] ? collect_hold_results(chunk) :
           collect_results(chunk)
end

# Hooks to run before and after chunks, this is form IJulia,
const preexecution_hooks = Function[]
push_preexecution_hook!(f::Function) = push!(preexecution_hooks, f)
function pop_preexecution_hook!(f::Function)
    i = findfirst(x -> x == f, preexecution_hooks)
    isnothing(i) && error("this function has not been registered in the pre-execution hook yet")
    return splice!(preexecution_hooks, i)
end
function execute_prehooks!(chunk::CodeChunk)
    for prehook in preexecution_hooks
        Base.invokelatest(prehook, chunk)
    end
end

const postexecution_hooks = Function[]
push_postexecution_hook!(f::Function) = push!(postexecution_hooks, f)
function pop_postexecution_hook!(f::Function)
    i = findfirst(x -> x == f, postexecution_hooks)
    isnothing(i) && error("this function has not been registered in the post-execution hook yet")
    return splice!(postexecution_hooks, i)
end
function execute_posthooks!(chunk::CodeChunk)
    for posthook in postexecution_hooks
        Base.invokelatest(posthook, chunk)
    end
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
    isnothing(fignum) && (fignum = get(report.chunk_fignums, chunk.number, 1))

    chunkid = isnothing(chunk.options[:label]) ? chunk.number : chunk.options[:label]
    basename = string(report.basename, '_', chunkid, '_', fignum, ext)
    full_name = normpath(report.cwd, chunk.options[:fig_path], basename)
    rel_name = string(chunk.options[:fig_path], '/', basename) # Relative path is used in output
    return full_name, rel_name
end

function set_rc_params(doc::WeaveDoc, fig_path, fig_ext)
    doc.chunk_defaults[:fig_ext] = isnothing(fig_ext) ? doc.format.fig_ext : fig_ext
    doc.chunk_defaults[:fig_path] = fig_path
end

function collect_results(chunk::CodeChunk)
    content = ""
    result_chunks = CodeChunk[]
    for r in chunk.result
        content *= r.code
        # Check if there is any output from chunk
        if any(!isempty ∘ strip, (r.stdout, r.rich_output)) || !isempty(r.figures)
            rchunk = CodeChunk(
                content,
                chunk.number,
                chunk.start_line,
                chunk.optionstring,
                copy(chunk.options),
            )
            rchunk.output = r.stdout
            rchunk.rich_output = r.rich_output
            rchunk.figures = r.figures
            push!(result_chunks, rchunk)
            content = ""
        end
    end
    if !isempty(content)
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
        output *= string('\n', indent_term_code(prompt, r.code), '\n', r.stdout)
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

function indent_term_code(prompt, code)
    prompt_with_space = string(prompt, ' ')
    n = length(prompt_with_space)
    pads = ' ' ^ n
    return map(enumerate(split(code, '\n'))) do (i,line)
        isone(i) ? string(prompt_with_space, line) : string(pads, line)
    end |> joinlines
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
