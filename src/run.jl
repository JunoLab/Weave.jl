using Base64


const PROGRESS_ID = "weave_progress"

"""
    run_doc(doc::WeaveDoc; kwargs...)

Run code chunks and capture output from the parsed document.

## Keyword options

- `doctype::Union{Nothing,AbstractString} = nothing`: Output document format. By default (i.e. given `nothing`), Weave will set it automatically based on file extension. You can also manually specify it; see [`list_out_formats()`](@ref) for the supported formats
- `out_path::Union{Symbol,AbstractString} = :doc`: Path where the output is generated can be either of:
  * `:doc`: Path of the source document (default)
  * `:pwd`: Julia working directory
  * `"somepath"`: `String` of output directory e.g. `"~/outdir"`, or of filename e.g. `"~/outdir/outfile.tex"`
- `args::Dict = Dict()`: Arguments to be passed to the weaved document; will be available as `WEAVE_ARGS` in the document
- `mod::Union{Module,Nothing} = nothing`: Module where Weave `eval`s code. You can pass a `Module` object, otherwise create an new sandbox module.
- `fig_path::AbstractString = "figures"`: Where figures will be generated, relative to `out_path`
- `fig_ext::Union{Nothing,AbstractString} = nothing`: Extension for saved figures e.g. `".pdf"`, `".png"`. Default setting depends on `doctype`
- `cache_path::AbstractString = "cache"`: Where of cached output will be saved
- `cache::Symbol = :off`: Controls caching of code:
  * `:off` means no caching (default)
  * `:all` caches everything
  * `:user` caches based on chunk options
  * `:refresh` runs all code chunks and save new cache
- `throw_errors::Bool = false`: If `false` errors are included in output document and the whole document is executed. If `true` errors are thrown when they occur

!!! note
    Run Weave from terminal and try to avoid weaving from IJulia or ESS; they tend to mess with capturing output.
"""
function run_doc(
    doc::WeaveDoc;
    doctype::Union{Nothing,AbstractString} = nothing,
    out_path::Union{Symbol,AbstractString} = :doc,
    args::Dict = Dict(),
    mod::Union{Module,Nothing} = nothing,
    fig_path::AbstractString = "figures",
    fig_ext::Union{Nothing,AbstractString} = nothing,
    cache_path::AbstractString = "cache",
    cache::Symbol = :off,
    throw_errors::Bool = false,
)
    # cache :all, :user, :off, :refresh

    doc.doctype = isnothing(doctype) ? (doctype = detect_doctype(doc.source)) : doctype
    doc.format = deepcopy(formats[doctype])

    doc.cwd = get_cwd(doc, out_path)
    isdir(doc.cwd) || mkpath(doc.cwd)
    if (occursin("2pdf", doctype) && cache == :off) || occursin("2html", doctype)
        fig_path = mktempdir(abspath(doc.cwd))
    end

    cache === :off || @eval import Serialization # XXX: evaluate in a more sensible module

    # This is needed for latex and should work on all output formats
    @static Sys.iswindows() && (fig_path = replace(fig_path, "\\" => "/"))

    set_rc_params(doc, fig_path, fig_ext)

    # New sandbox for each document with args exposed
    isnothing(mod) && (mod = sandbox = Core.eval(Main, :(module $(gensym(:WeaveSandBox)) end))::Module)
    @eval mod WEAVE_ARGS = $args

    mimetypes = get(doc.format.formatdict, :mimetypes, default_mime_types)

    report = Report(doc.cwd, doc.basename, doc.format.formatdict, mimetypes, throw_errors)
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
    result = eval_chunk(chunk, report, mod)
    occursin("2html", report.formatdict[:doctype]) && (embed_figures!(result, report.cwd))
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

run_inline(inline::InlineText, doc::WeaveDoc, report::Report, SandBox::Module) = inline

const INLINE_OPTIONS = Dict(
    :term => false,
    :hold => true,
    :wrap => false
)

function run_inline(inline::InlineCode, doc::WeaveDoc, report::Report, SandBox::Module)
    # Make a temporary CodeChunk for running code. Collect results and don't wrap
    chunk = CodeChunk(inline.content, 0, 0, "", INLINE_OPTIONS)
    options = merge(doc.chunk_defaults, chunk.options)
    merge!(chunk.options, options)

    chunks = eval_chunk(chunk, report, SandBox)
    occursin("2html", report.formatdict[:doctype]) && (embed_figures!(chunks, report.cwd))

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

function run_code(chunk::CodeChunk, report::Report, SandBox::Module)
    expressions = parse_input(chunk.content)
    N = length(expressions)
    # @show expressions
    result_no = 1
    results = ChunkOutput[]

    for (str_expr, expr) in expressions
        reset_report(report)
        lastline = (result_no == N)
        (obj, out) = capture_output(
            expr,
            SandBox,
            chunk.options[:term],
            chunk.options[:display],
            lastline,
            report.throw_errors,
        )
        figures = report.figures # Captured figures
        result = ChunkOutput(str_expr, out, report.cur_result, report.rich_output, figures)
        report.rich_output = ""
        push!(results, result)
        result_no += 1
    end
    return results
end

# TODO: run in document source path
function capture_output(expr, SandBox::Module, term, disp, lastline, throw_errors = false)
    out = nothing
    obj = nothing
    old = stdout
    rw, wr = redirect_stdout()
    reader = @async read(rw, String)
    try
        obj = Core.eval(SandBox, expr)
        !isnothing(obj) && ((term || disp) || lastline) && display(obj)
    catch err
        throw_errors && throw(err)
        display(err)
        @warn "ERROR: $(typeof(err)) occurred, including output in Weaved document"
    finally
        redirect_stdout(old)
        close(wr)
        out = fetch(reader)
        close(rw)
    end
    out = replace(out, r"\u001b\[.*?m" => "") # remove ANSI color codes
    return (obj, out)
end

# Parse chunk input to array of expressions
function parse_input(s)
    res = []
    s = lstrip(s)
    n = sizeof(s)
    pos = 1 # The first character is extra line end
    while (oldpos = pos) ≤ n
        ex, pos = Meta.parse(s, pos)
        push!(res, (s[oldpos:pos-1], ex))
    end
    return res
end

function eval_chunk(chunk::CodeChunk, report::Report, SandBox::Module)
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

    if haskey(report.formatdict, :out_width) && isnothing(chunk.options[:out_width])
        chunk.options[:out_width] = report.formatdict[:out_width]
    end

    chunk.result = run_code(chunk, report, SandBox)

    # Run post_execute chunks
    for hook in postexecute_hooks
        chunk = Base.invokelatest(hook, chunk)
    end

    if chunk.options[:term]
        chunks = collect_results(chunk, TermResult())
    elseif chunk.options[:hold]
        chunks = collect_results(chunk, CollectResult())
    else
        chunks = collect_results(chunk, ScriptResult())
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
    figpath = joinpath(report.cwd, chunk.options[:fig_path])
    isdir(figpath) || mkpath(figpath)
    isnothing(ext) && (ext = chunk.options[:fig_ext])
    isnothing(fignum) && (fignum = report.fignum)

    chunkid = isnothing(chunk.options[:label]) ? chunk.number : chunk.options[:label]
    full_name = joinpath(
        report.cwd,
        chunk.options[:fig_path],
        "$(report.basename)_$(chunkid)_$(fignum)$ext",
    )
    rel_name = "$(chunk.options[:fig_path])/$(report.basename)_$(chunkid)_$(fignum)$ext" # Relative path is used in output
    return full_name, rel_name
end

function get_cwd(doc::WeaveDoc, out_path)
    # Set the output directory
    if out_path == :doc
        cwd = doc.path
    elseif out_path == :pwd
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
    isnothing(ext) && (ext = doc.format.formatdict[:extension])
    outname = "$(doc.cwd)/$(doc.basename).$ext"
end

"""Get output file name based on out_path"""
function get_outname(out_path::AbstractString, doc::WeaveDoc; ext = nothing)
    isnothing(ext) && (ext = doc.format.formatdict[:extension])
    splitted = splitext(out_path)
    if (splitted[2]) == ""
        outname = "$(doc.cwd)/$(doc.basename).$ext"
    else
        outname = expanduser(out_path)
    end
end

function set_rc_params(doc::WeaveDoc, fig_path, fig_ext)
    formatdict = doc.format.formatdict
    if isnothing(fig_ext)
        doc.chunk_defaults[:fig_ext] = formatdict[:fig_ext]
    else
        doc.chunk_defaults[:fig_ext] = fig_ext
    end
    doc.chunk_defaults[:fig_path] = fig_path
    return nothing
end

function collect_results(chunk::CodeChunk, fmt::ScriptResult)
    content = ""
    result_no = 1
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
            rchunk.result_no = result_no
            result_no *= 1
            rchunk.figures = r.figures
            rchunk.output = r.stdout * r.displayed
            rchunk.rich_output = r.rich_output
            push!(result_chunks, rchunk)
        end
    end
    if content != ""
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

function collect_results(chunk::CodeChunk, fmt::TermResult)
    output = ""
    prompt = chunk.options[:prompt]
    result_no = 1
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
    if output != ""
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

function collect_results(chunk::CodeChunk, fmt::CollectResult)
    result_no = 1
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
