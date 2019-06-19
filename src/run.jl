using Base64

"""
    run(doc::WeaveDoc; doctype = :auto,
        mod::Union{Module, Symbol} = :sandbox, out_path=:doc,
        args=Dict(), fig_path = "figures", fig_ext = nothing,
        cache_path = "cache", cache = :off, throw_errors=false)

Run code chunks and capture output from parsed document.

* `doctype`: :auto = set based on file extension or specify one of the supported formats.
  See `list_out_formats()`
* `out_path`: Path where the output is generated. Can be: `:doc`: Path of the source document, `:pwd`: Julia working directory,
  `"somepath"`: Path as a AbstractString e.g `"/home/mpastell/weaveout"`
* `args`: dictionary of arguments to pass to document. Available as WEAVE_ARGS.
* `mod`: Module where Weave `eval`s code. Defaults to `:sandbox`
   to create new sandbox module, you can also pass a module e.g. `Main`.
* `fig_path`: where figures will be generated, relative to out_path
* `fig_ext`: Extension for saved figures e.g. `".pdf"`, `".png"`. Default setting depends on `doctype`.
* `cache_path`: where of cached output will be saved.
* `cache`: controls caching of code: `:off` = no caching, `:all` = cache everything,
  `:user` = cache based on chunk options, `:refresh`, run all code chunks and save new cache.

**Note:** Run command from terminal and not using IJulia, Juno or ESS, they tend to mess with capturing output.
"""
function Base.run(doc::WeaveDoc; doctype = :auto,
        mod::Union{Module, Symbol} = :sandbox, out_path=:doc,
        args=Dict(), fig_path = "figures", fig_ext = nothing,
        cache_path = "cache", cache = :off, throw_errors=false)
    #cache :all, :user, :off, :refresh

    doc.cwd = get_cwd(doc, out_path)
    doctype == :auto && (doctype = detect_doctype(doc.source))
    doc.doctype = doctype
    doc.format = formats[doctype]
    isdir(doc.cwd) || mkpath(doc.cwd)

    if occursin("2pdf", doctype) && cache == :off
        fig_path = mktempdir(abspath(doc.cwd))
    elseif occursin("2html", doctype)
        fig_path = mktempdir(abspath(doc.cwd))
    end

    cache == :off || @eval import Serialization

    #This is needed for latex and should work on all output formats
    Sys.iswindows() && (fig_path = replace(fig_path, "\\" => "/"))

    doc.fig_path = fig_path
    set_rc_params(doc, fig_path, fig_ext)

    #New sandbox for each document with args exposed
    if mod == :sandbox
        sandbox = "WeaveSandBox$(rcParams[:doc_number])"
        mod = Core.eval(Main, Meta.parse("module $sandbox\nend"))
    end
    @eval mod WEAVE_ARGS = Dict()
    merge!(mod.WEAVE_ARGS, args)

    rcParams[:doc_number] += 1

    if haskey(doc.format.formatdict, :mimetypes)
      mimetypes = doc.format.formatdict[:mimetypes]
    else
      mimetypes = default_mime_types
    end

    report = Report(doc.cwd, doc.basename, doc.format.formatdict, mimetypes, throw_errors)
    pushdisplay(report)

    if cache != :off && cache != :refresh
        cached = read_cache(doc, cache_path)
        cached == nothing && @info("No cached results found, running code")
    else
        cached = nothing
    end

    executed = Any[]
    n = length(doc.chunks)

    for i = 1:n
        chunk = doc.chunks[i]

        if isa(chunk, CodeChunk)
            options = merge(doc.chunk_defaults, chunk.options)
            merge!(chunk.options, options)
        end

        restore = (cache ==:user && typeof(chunk) == CodeChunk && chunk.options[:cache])

        if cached != nothing && (cache == :all || restore)
            result_chunks = restore_chunk(chunk, cached)
        else
            result_chunks = run_chunk(chunk, doc, report, mod)
        end

        executed = [executed; result_chunks]
    end

    doc.header_script = report.header_script

    popdisplay(report)

    #Clear variables from used sandbox
    mod == :sandbox && clear_sandbox(SandBox)
    doc.chunks = executed

    if cache != :off
        write_cache(doc, cache_path)
    end

    return doc
end

"""Detect the output format based on file extension"""
function detect_doctype(source::AbstractString)
  ext = lowercase(splitext(source)[2])
  ext == ".jl" && return "md2html"
  occursin("md", ext) && return "md2html"
  occursin("rst", ext) && return "rst"
  occursin("tex", ext) && return "texminted"
  occursin("txt", ext) && return "asciidoc"

  return "pandoc"
end


function run_chunk(chunk::CodeChunk, doc::WeaveDoc, report::Report, SandBox::Module)
    @info("Weaving chunk $(chunk.number) from line $(chunk.start_line)")
    result_chunks = eval_chunk(chunk, report, SandBox)
    occursin("2html", report.formatdict[:doctype]) && (result_chunks = embed_figures(result_chunks, report.cwd))
    return result_chunks
end

function embed_figures(chunk::CodeChunk, cwd)
    chunk.figures = [img2base64(fig, cwd) for fig in chunk.figures]
    return chunk
end

function embed_figures(result_chunks, cwd)
    for i in 1:length(result_chunks)
        figs = result_chunks[i].figures
        if !isempty(figs)
            result_chunks[i].figures = [img2base64(fig, cwd) for fig in figs]
        end
    end
    return result_chunks
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
    return(fig)
  end
end

function run_chunk(chunk::DocChunk, doc::WeaveDoc, report::Report, SandBox::Module)
    chunk.content =  [run_inline(c, doc, report, SandBox) for c in chunk.content]
    return chunk
end

function run_inline(inline::InlineText, doc::WeaveDoc, report::Report, SandBox::Module)
    return inline
end

function run_inline(inline::InlineCode, doc::WeaveDoc, report::Report, SandBox::Module)
    #Make a temporary CodeChunk for running code. Collect results and don't wrap
    chunk = CodeChunk(inline.content, 0, 0, "", Dict(:hold => true, :wrap => false))
    options = merge(doc.chunk_defaults, chunk.options)
    merge!(chunk.options, options)

    chunks = eval_chunk(chunk, report, SandBox)
    occursin("2html", report.formatdict[:doctype]) && (chunks = embed_figures(chunks, report.cwd))

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
    #@show expressions
    result_no = 1
    results = ChunkOutput[ ]

    for (str_expr, expr) = expressions
        reset_report(report)
        lastline = (result_no == N)
        (obj, out) = capture_output(expr, SandBox, chunk.options[:term],
                      chunk.options[:display], lastline, report.throw_errors)
        figures = report.figures #Captured figures
        result = ChunkOutput(str_expr, out, report.cur_result, report.rich_output, figures)
        report.rich_output = ""
        push!(results, result)
        result_no += 1
    end
    return results
end

getstdout() = stdout

function capture_output(expr, SandBox::Module, term, disp,
                        lastline, throw_errors=false)
    #oldSTDOUT = STDOUT
    oldSTDOUT = getstdout()
    out = nothing
    obj = nothing
    rw, wr = redirect_stdout()
    reader = @async read(rw, String)
    try
        obj = Core.eval(SandBox, expr)
        if (term || disp) && typeof(expr) == Expr && expr.head != :toplevel
            obj != nothing && display(obj)
        elseif typeof(expr) == Symbol
            display(obj)
        #This shows images and lone variables, result can
        #Handle last line sepately
        elseif lastline && obj != nothing
            (expr.head != :toplevel) && display(obj)
        end
    catch E
        throw_errors && throw(E)
        display(E)
        @warn("ERROR: $(typeof(E)) occurred, including output in Weaved document")
    finally
        redirect_stdout(oldSTDOUT)
        close(wr)
        out = fetch(reader)
        close(rw)
    end
    out = replace(out, r"\u001b\[.*?m" => "") #Remove ANSI color codes
    return (obj, out)
end


#Parse chunk input to array of expressions
function parse_input(input::AbstractString)
    parsed = Tuple{AbstractString, Any}[]
    input = lstrip(input)
    n = sizeof(input)
    pos = 1 #The first character is extra line end
    while pos ≤ n
        oldpos = pos
        code,  pos = Meta.parse(input, pos)
        push!(parsed, (input[oldpos:pos-1] , code ))
    end
    parsed
end


function eval_chunk(chunk::CodeChunk, report::Report, SandBox::Module)
    if !chunk.options[:eval]
        chunk.output = ""
        chunk.options[:fig] = false
        return chunk
    end

    #Run preexecute_hooks
    for hook in preexecute_hooks
      chunk = Compat.invokelatest(hook, chunk)
    end

    report.fignum = 1
    report.cur_chunk = chunk

    if haskey(report.formatdict, :out_width) && chunk.options[:out_width] == nothing
        chunk.options[:out_width] = report.formatdict[:out_width]
    end

    chunk.result = run_code(chunk, report, SandBox)


    #Run post_execute chunks
    for hook in postexecute_hooks
      chunk = Compat.invokelatest(hook, chunk)
    end

    if chunk.options[:term]
        chunks = collect_results(chunk, TermResult())
    elseif chunk.options[:hold]
        chunks = collect_results(chunk, CollectResult())
    else
        chunks = collect_results(chunk, ScriptResult())
    end

      #else
     #   chunk.options[:fig] && (chunk.figures = copy(report.figures))
    #end

    chunks
end


#function eval_chunk(chunk::DocChunk, report::Report, SandBox)
#    chunk
#end

#Set all variables to nothing
function clear_sandbox(SandBox::Module)
    for name = names(SandBox, all=true)
        if name != :eval && name != names(SandBox)[1]
            try eval(SandBox, Meta.parse(AbstractString(AbstractString(name), "=nothing"))) catch; end
        end
    end
end


function get_figname(report::Report, chunk; fignum = nothing, ext = nothing)
    figpath = joinpath(report.cwd, chunk.options[:fig_path])
    isdir(figpath) || mkpath(figpath)
    ext == nothing && (ext = chunk.options[:fig_ext])
    fignum == nothing && (fignum = report.fignum)

    chunkid = (chunk.options[:label] == nothing) ? chunk.number : chunk.options[:label]
    full_name = joinpath(report.cwd, chunk.options[:fig_path],
        "$(report.basename)_$(chunkid)_$(fignum)$ext")
    rel_name = "$(chunk.options[:fig_path])/$(report.basename)_$(chunkid)_$(fignum)$ext" #Relative path is used in output
    return full_name, rel_name
end

function get_cwd(doc::WeaveDoc, out_path)
    #Set the output directory
    if out_path == :doc
        cwd = doc.path
    elseif out_path == :pwd
        cwd = pwd()
    else
        #If there is no extension, use as path
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
    ext == nothing && (ext = doc.format.formatdict[:extension])
    outname = "$(doc.cwd)/$(doc.basename).$ext"
end


"""Get output file name based on out_path"""
function get_outname(out_path::AbstractString, doc::WeaveDoc; ext = nothing)
    ext == nothing && (ext = doc.format.formatdict[:extension])
    splitted = splitext(out_path)
    if (splitted[2]) == ""
        outname = "$(doc.cwd)/$(doc.basename).$ext"
    else
        outname = expanduser(out_path)
    end
end

function set_rc_params(doc::WeaveDoc, fig_path, fig_ext)
    formatdict = doc.format.formatdict
    if fig_ext == nothing
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
    result_chunks = CodeChunk[ ]
    for r = chunk.result
        #Check if there is any output from chunk
        if strip(r.stdout) == "" && isempty(r.figures)  && strip(r.rich_output) == ""
            content *= r.code
        else
            content = "\n" * content * r.code
            rchunk = CodeChunk(content, chunk.number, chunk.start_line, chunk.optionstring, copy(chunk.options))
            content = ""
            rchunk.result_no = result_no
            result_no *=1
            rchunk.figures = r.figures
            rchunk.output = r.stdout * r.displayed
            rchunk.rich_output = r.rich_output
            push!(result_chunks, rchunk)
        end
    end
    if content != ""
        startswith(content, "\n") || (content = "\n" * content)
        rchunk = CodeChunk(content, chunk.number, chunk.start_line, chunk.optionstring, copy(chunk.options))
        push!(result_chunks, rchunk)
    end

    return result_chunks
end

function collect_results(chunk::CodeChunk, fmt::TermResult)
    output = ""
    prompt = chunk.options[:prompt]
    result_no = 1
    result_chunks = CodeChunk[ ]
    for r = chunk.result
        output *= prompt * r.code
        output *= r.displayed * r.stdout
        if !isempty(r.figures)
            rchunk = CodeChunk("", chunk.number, chunk.start_line, chunk.optionstring, copy(chunk.options))
            rchunk.output = output
            output = ""
            rchunk.figures = r.figures
            push!(result_chunks, rchunk)
        end
    end
    if output != ""
         rchunk = CodeChunk("", chunk.number, chunk.start_line, chunk.optionstring, copy(chunk.options))
         rchunk.output = output
        push!(result_chunks, rchunk)
    end

    return result_chunks
end

function collect_results(chunk::CodeChunk, fmt::CollectResult)
    result_no = 1
    for r =chunk.result
        chunk.output *=  r.stdout
        chunk.rich_output *= r.rich_output
        chunk.figures = [chunk.figures; r.figures]
    end
    return [chunk]
end
