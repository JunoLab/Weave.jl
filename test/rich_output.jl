using Weave, Compat
using Base.Test

function mmtest(source, resfile, doctype)
  weave("documents/$source", out_path = "documents/multimedia/$resfile", doctype=doctype, plotlib=nothing)
  result = @compat readstring(open("documents/multimedia/$resfile"))
  ref = @compat readstring(open("documents/multimedia/$resfile.ref"))
  @test result == ref
end

mmtest("rich_output.jmd", "rich_output.md", "pandoc")
mmtest("rich_output.jmd", "rich_output.tex", "tex")
