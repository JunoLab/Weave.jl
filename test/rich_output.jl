using Weave
using Test

function mmtest(source, resfile, doctype)
  weave("documents/$source", out_path = "documents/multimedia/$resfile", mod=:sandbox,
    doctype=doctype, template = "templates/mini.tpl")
  result =  read("documents/multimedia/$resfile", String)
  ref =  read("documents/multimedia/$resfile.ref", String)
  @test result == ref
  rm("documents/multimedia/$resfile")
end

mmtest("rich_output.jmd", "rich_output.html", "md2html")
mmtest("rich_output.jmd", "rich_output.md", "pandoc")
mmtest("rich_output.jmd", "rich_output.tex", "tex")
mmtest("rich_output.jmd", "rich_output.github", "github")
