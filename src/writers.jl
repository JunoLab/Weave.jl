import JSON
import Mustache

mutable struct NotebookOutput
end

mutable struct MarkdownOutput
end

mutable struct NowebOutput
end

mutable struct ScriptOutput
end

const output_formats = Dict{String, Any}(
  "noweb" => NowebOutput(),
  "notebook" => NotebookOutput(),
  "markdown" => MarkdownOutput(),
  "script" => ScriptOutput()
)

"""Autodetect format for converter"""
function detect_outformat(outfile::String)
  ext = lowercase(splitext(outfile)[2])

  ext == ".jl" && return "script"
  ext == ".jmd" && return "markdown"
  ext == ".ipynb" && return "notebook"
  return "noweb"
end

"""
`convert_doc(infile::AbstractString, outfile::AbstractString; format = nothing)`

Convert Weave documents between different formats

* `infile` = Name of the input document
* `outfile` = Name of the output document
* `format` = Output format (optional). Detected from outfile extension, but can
  be set to `"script"`, `"markdown"`, `"notebook"` or `"noweb"`.
"""
function convert_doc(infile::AbstractString, outfile::AbstractString; format = nothing)
  doc = read_doc(infile)

  if format == nothing
    format = detect_outformat(outfile)
  end

  converted = convert_doc(doc, output_formats[format])

  open(outfile, "w") do f
    write(f, converted)
  end

  return nothing
end

"""Convert Weave document to Jupyter notebook format"""
function convert_doc(doc::WeaveDoc, format::NotebookOutput)
    nb = Dict()
    nb["nbformat"] =  4
    nb["nbformat_minor"] = 2
    metadata = Dict()
    kernelspec = Dict()
    kernelspec["language"] =  "julia"
    kernelspec["name"] =  "julia-$(VERSION.major).$(VERSION.minor)"
    kernelspec["display_name"] = "Julia $(VERSION.major).$(VERSION.minor).$(VERSION.patch)"
    metadata["kernelspec"] = kernelspec
    language_info = Dict()
    language_info["file_extension"] = ".jl"
    language_info["mimetype"] = "application/julia"
    language_info["name"]=  "julia"
    language_info["version"] = "$(VERSION.major).$(VERSION.minor).$(VERSION.patch)"
    metadata["language_info"] = language_info
    cells = []
    ex_count = 1

    # Handle header
    head_tpl = """
    {{#:title}}# {{:title}}{{/:title}}
    {{#:author}}### {{{:author}}}{{/:author}}
    {{#:date}}### {{{:date}}}{{/:date}}
    """

    if isa(doc.chunks[1], DocChunk)
        doc.chunks[1] = strip_header(doc.chunks[1])
        doc.chunks[1].content[1].content = Mustache.render(head_tpl;
              [Pair(Symbol(k), v) for (k,v) in doc.header]...) * doc.chunks[1].content[1].content
    end

    for chunk in doc.chunks

        if isa(chunk, DocChunk)
            push!(cells,
              Dict("cell_type" => "markdown",
                 "metadata" => Dict(),
              "source" => [strip(join([repr(c) for c in chunk.content], ""))])
                 )
        elseif haskey(chunk.options, :skip) && chunk.options[:skip] == "notebook"
            continue
        else
            push!(cells,
            Dict("cell_type" => "code",
               "metadata" => Dict(),
               "source" => [strip(chunk.content)],
               "execution_count" => nothing,
               "outputs" => []
               ))
       end
   end

    nb["cells"] = cells
    nb["metadata"] = metadata

    json_nb = JSON.json(nb, 2)
    return json_nb
end

"""Convert Weave document to Jupyter notebook format"""
function convert_doc(doc::WeaveDoc, format::MarkdownOutput)
  output = ""
  for chunk in doc.chunks
    if isa(chunk, DocChunk)
      output *= join([repr(c) for c in chunk.content], "")
    else
      output *= "\n" * "```julia"
      isempty(chunk.optionstring) || (output *= ";" * chunk.optionstring)
      output *= "\n" * lstrip(chunk.content)
      output *= "```\n"
    end
  end

  return output
end

"""Convert Weave document to noweb format"""
function convert_doc(doc::WeaveDoc, format::NowebOutput)
  output = ""
  for chunk in doc.chunks
    if isa(chunk, DocChunk)
      output *= join([repr(c) for c in chunk.content], "")
    else
      output *= "\n" * "<<"
      isempty(chunk.optionstring) || (output *= strip(chunk.optionstring))
      output *= ">>="
      output *= "\n" * lstrip(chunk.content)
      output *= "@\n"
    end
  end

  return output
end

"""Convert Weave document to script format"""
function convert_doc(doc::WeaveDoc, format::ScriptOutput)
  output = ""
  for chunk in doc.chunks
    if typeof(chunk) == Weave.DocChunk
      content = join([repr(c) for c in chunk.content], "")
      output *= join(["#' " * s for s in split(content, "\n")], "\n")
    else
      output *= "\n#+ "
      isempty(chunk.optionstring) || (output *= strip(chunk.optionstring))
      output *= "\n\n" * lstrip(chunk.content)
      output *= "\n"
    end
  end

  return output
end

function Base.repr(c::InlineText)
  return c.content
end

function Base.repr(c::InlineCode)
  return "`j $(c.content)`"
end
