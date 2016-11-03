using Weave
using Base.Test

function mmtest(source, resfile, doctype)
  weave("documents/$source", out_path = "documents/multimedia/$resfile", doctype=doctype, plotlib=nothing)
  result =  readstring(open("documents/multimedia/$resfile"))
  ref =  readstring(open("documents/multimedia/$resfile.ref"))
  @test result == ref
end

mmtest("rich_output.jmd", "rich_output.md", "pandoc")
mmtest("rich_output.jmd", "rich_output.tex", "tex")
