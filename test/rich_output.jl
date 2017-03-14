using Weave
using Base.Test

function mmtest(source, resfile, doctype)
  VER = "$(VERSION.major).$(VERSION.minor)"
  weave("documents/$source", out_path = "documents/multimedia/$resfile", doctype=doctype, plotlib=nothing)
  result =  readstring("documents/multimedia/$resfile")
  ref =  readstring("documents/multimedia/$VER/$resfile.ref")
  @test result == ref
  rm("documents/multimedia/$resfile")
end

mmtest("rich_output.jmd", "rich_output.md", "pandoc")
mmtest("rich_output.jmd", "rich_output.tex", "tex")
