#Contains report global properties
type Report <: Display
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
end

function Report(cwd, basename, formatdict, mimetypes)
    Report(cwd, basename, formatdict, "", "", "", 1, AbstractString[], :text, nothing, mimetypes, true, "")
end


#Default mimetypes in order, can be overridden for some inside `run method` formats
const default_mime_types = ["image/svg+xml", "image/png", "text/html", "text/plain"]
#const default_mime_types = ["image/png", "image/svg+xml", "text/html", "text/plain"]
#From IJulia as a reminder
#const supported_mime_types = [ "text/html", "text/latex", "image/svg+xml", "image/png", "image/jpeg", "text/plain", "text/markdown" ]

function Base.display(report::Report, data)
    #Set preferred mimetypes for report based on format
    for m in report.mimetypes
        if mimewritable(m, data)
            info(data)
            try
              display(report, m, data)
            catch
              warn("Failed to save image in \"$m\" format")
              continue
            end
            #Always show plain text as well for term mode
            if m ≠ "text/plain" && report.cur_chunk.options[:term]
              display(report, "text/plain", data)
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
    figname = add_figure(report, m, data, ".pdf")
end

#Text is written to stdout, called from "term" mode chunks
function Base.display(report::Report, m::MIME"text/plain", data)
    s = reprmime(m, data)
    print("\n" * s)
end

#Catch "rich_output"
function Base.display(report::Report, m::MIME"text/html", data)
    s = reprmime(m, data)
    report.rich_output *= "\n" * s
end

#Catch "rich_output"
function Base.display(report::Report, m::MIME"text/markdown", data)
    s = reprmime(m, data)
    report.rich_output *= "\n" * s
end

function Base.display(report::Report, m::MIME"text/latex", data)
    s = reprmime(m, data)
    report.rich_output *= "\n" * s
end


"""Add saved figure name to results and return the name"""
function add_figure(report::Report, data, m, ext)
  chunk = report.cur_chunk
  full_name, rel_name = get_figname(report, chunk, ext = ext)

  open(full_name, "w") do io
    show(io, m, data)
  end

  push!(report.figures, rel_name)
  report.fignum += 1
  return full_name
end
