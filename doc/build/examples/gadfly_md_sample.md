% Intro to Weave.jl with Gadfly
% Matti Pastell
% 20th April 2016

# Introduction

This a sample [Julia](http://julialang.org/) noweb document that can
be executed using [Weave.jl](https://github.com/mpastell/Weave.jl).

The code is delimited from docs using markdown fenced code blocks
markup which can be seen looking at the source document [gadfly_md_sample.jmd](gadfly_md_sample.jmd)
in the examples directory of the package. The source document can be executed
 and the results with Gadfly plots are captured in the resulting file.

You can create markdown output or pdf and HTML directly (with Pandoc) using
the weave command as follows:

````julia
using Weave
#Markdown
weave(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"), informat="markdown",
  out_path = :pwd, doctype = "pandoc")
#HTML
weave(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"), informat="markdown",
  out_path = :pwd, doctype = "md2html")
#pdf
weave(Pkg.dir("Weave","examples","gadfly_md_sample.jmd"), informat="markdown",
  out_path = :pwd, doctype = "md2pdf")
````




*The documents will be written to the Julia working directory when you
use the `out_path = :pwd`.*

# Capturing code

The basic code chunk will be run with default options and the code and
output will be captured.

````julia
using Gadfly
x = linspace(0, 2*pi)
println(x)

````


````
linspace(0.0,6.283185307179586,50)
````



````julia
plot(x = x, y = sin(x))
````


![](figures/gadfly_md_sample_2_1.pdf)\ 




You can also control the way the results are captured, plot size etc.
using chunk options. Here is an example of a chunk that behaves like a repl.

````julia
julia> x = 1:10

1:10
julia> d = Dict("Weave" => "testing")

Dict{String,String} with 1 entry:
  "Weave" => "testing"
julia> y = [2, 4 ,8]
3-element Array{Int64,1}:
 2
 4
 8
````





You can also for instance hide the code and show only the figure, add a
caption to the figure and make it wider as follows (you can only see the
syntax from the source document):

![A random walk.](figures/gadfly_md_sample_random_1.pdf)



# Whats next

Read the documentation:

  - stable: <http://mpastell.github.io/Weave.jl/stable/>
  - latest: <http://mpastell.github.io/Weave.jl/latest/>

See other examples in: <https://github.com/mpastell/Weave.jl/tree/master/examples>
