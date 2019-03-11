using Compat
using Markdown
import .WeaveMarkdown

#Contains report global properties
mutable struct Report <: AbstractDisplay
  cwd::AbstractString
  basename::AbstractString
  formatdict::Dict{Symbol,Any}
  pending_code::AbstractString
  cur_result::AbstractString
  rich_output::AbstractString
  fignum::Int
  figures::Array{AbstractString}
  term_state::Symbol
  cur_chunk
  mimetypes::Array{AbstractString}
  first_plot::Bool
  header_script::String
  throw_errors::Bool
end

function Report(cwd, basename, formatdict, mimetypes, throw_errors)
    Report(cwd, basename, formatdict, "", "", "", 1, AbstractString[], :text, nothing,
        mimetypes, true, "", throw_errors)
end


#Default mimetypes in order, can be overridden for some inside `run method` formats
const default_mime_types = ["image/svg+xml", "image/png", "text/html", "text/plain"]
#const default_mime_types = ["image/png", "image/svg+xml", "text/html", "text/plain"]
#From IJulia as a reminder
#const supported_mime_types = [ "text/html", "text/latex", "image/svg+xml", "image/png", "image/jpeg", "text/plain", "text/markdown" ]

const mimetype_ext =
    Dict(".png" => "image/png",
         ".jpg" => "image/jpeg",
         ".jpeg" => "image/jpeg",
         ".svg" => "image/svg+xml",
         ".js.svg" => "image/svg+xml",
         ".pdf" => "application/pdf",
         ".ps" => "application/postscript",
         ".tex" => "text/latex"
         )

function Base.display(report::Report, data)
    #Set preferred mimetypes for report based on format
    fig_ext = report.cur_chunk.options[:fig_ext]
    for m in unique([mimetype_ext[fig_ext] ; report.mimetypes])
        if Base.invokelatest(showable, m, data)
            try
                if !istextmime(m)
                    Compat.invokelatest(display, report, m, data)
                elseif report.cur_chunk.options[:term]
                    Compat.invokelatest(display, report, "text/plain", data)
                else
                    Compat.invokelatest(display, report, m, data)
                end
            catch e
                throw(e)
                @warn("Failed to display data in \"$m\" format")
                continue
            end
            break
        end
    end
end

function Base.display(report::Report, m::MIME"image/png", data)
    figname = add_figure(report, data, m, ".png")
end

function Base.display(report::Report, m::MIME"image/svg+xml", data)
    figname = add_figure(report, data, m, ".svg")
end

function Base.display(report::Report, m::MIME"application/pdf", data)
    figname = add_figure(report, data, m, ".pdf")
end

#Text is written to stdout, called from "term" mode chunks
function Base.display(report::Report, m::MIME"text/plain", data)
    io = PipeBuffer()
    show(IOContext(io, :limit => true), m, data)
    flush(io)
    s = read(io, String)
    close(io)
    println(s)
end

function Base.display(report::Report, m::MIME"text/plain", data::Exception)
    println("Error: " * sprint(showerror, data))
end

function Base.display(report::Report, m::MIME"text/html", data::Exception)
    report.rich_output = sprint(show, m, data)
end

function Base.show(io, m::MIME"text/html", data::Exception)
    println(io ,"<pre class=\"julia-error\">")
    println(io, Markdown.htmlesc("ERROR: " * sprint(showerror, data)))
    println(io ,"</pre>")
end

#Catch "rich_output"
function Base.display(report::Report, m::MIME"text/html", data)
    s = repr(m, data)
    report.rich_output *= "\n" * s
end

#Catch "rich_output"
function Base.display(report::Report, m::MIME"text/markdown", data)
    s = repr(m, data)
    # Convert to "richer" type of possible
    for m in report.mimetypes
        if m == "text/html" || m == "text/latex"
            display(Markdown.parse(s, flavor=WeaveMarkdown.weavemd))
            break
        elseif m == "text/markdown"
            report.rich_output *= "\n" * s
            break
        end
    end
end

function Base.display(report::Report, m::MIME"text/latex", data)
    s = repr(m, data)
    report.rich_output *= "\n" * s
end

"""Add saved figure name to results and return the name"""
function add_figure(report::Report, data, m, ext)
  chunk = report.cur_chunk
  full_name, rel_name = get_figname(report, chunk, ext = ext)

  open(full_name, "w") do io
      if ext == ".pdf"
          write(io, repr(m, data))
      else
          show(io, m, data)
      end
  end

  push!(report.figures, rel_name)
  report.fignum += 1
  return full_name
end
