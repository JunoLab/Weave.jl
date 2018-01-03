using Weave
using Base.Test

function mmtest(source, resfile, doctype)
  weave("documents/$source", out_path = "documents/multimedia/$resfile", 
    doctype=doctype, plotlib=nothing, template = "templates/mini.tpl")
  result =  readstring("documents/multimedia/$resfile")
  ref =  readstring("documents/multimedia/$resfile.ref")
  @test result == ref
  rm("documents/multimedia/$resfile")
end

mmtest("rich_output.jmd", "rich_output.md", "pandoc")
mmtest("rich_output.jmd", "rich_output.tex", "tex")
mmtest("rich_output.jmd", "rich_output.html", "md2html")
mmtest("rich_output.jmd", "rich_output.github", "github")
