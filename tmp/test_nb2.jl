import Weave, JSON

doc = Weave.read_doc("examples/FIR_design_plots.jl")

nb = Weave.convert_doc(doc, Weave.NotebookOutput())
md = Weave.convert_doc(doc, Weave.MarkdownOutput())
noweb = Weave.convert_doc(doc, Weave.NowebOutput())
script = Weave.convert_doc(doc, Weave.ScriptOutput())

Weave.convert_doc("examples/FIR_design_plots.jl",
                    "tmp/test3.ipynb")


Weave.convert_doc("examples/FIR_design_plots.jl",
                    "tmp/test3.jmd")

Weave.convert_doc("examples/FIR_design_plots.jl",
                    "tmp/FIR.jl")


#chunk = doc.chunks[1]
#Weave.output_formats
