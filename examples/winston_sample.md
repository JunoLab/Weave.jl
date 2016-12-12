
# Introducion to Weave

This a sample [Julia](http://julialang.org/) noweb document that can
be executed using Weave. Output from code chunks and Winston
plots will be included in the weaved document. You also need to install Pweave from Github in order to use Weave.

This documented can be turned into Pandoc markdown with captured
result from Julia prompt.

~~~~{.julia}
using Weave
weave(Pkg.dir("Weave","examples","winston_sample.mdw"), plotlib="Winston")
~~~~

## Terminal chunk

~~~~{.julia}
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
~~~~~~~~~~~~~





## Capturing figures

The figures and code can be included in the output.

~~~~{.julia}
julia> using Winston

julia> t = linspace(0, 2*pi, 100)

100-element LinSpace{Float64}:
 0.0,0.0634665,0.126933,0.1904,0.253866,…,6.09279,6.15625,6.21972,6.28319
julia> p = plot(t, sinc(t))
Winston.FramedPlot(...)
~~~~~~~~~~~~~


![](figures/winston_sample_2_1.png)\ 




You can also include a plot with caption and hide the code:

![Random walk.](figures/winston_sample_random_1.png)



~~~~{.julia}
x = linspace(0, 3pi, 100)
c = cos(x)
s = sin(x)

p = FramedPlot(
         title="title!",
         xlabel="\\Sigma x^2_i",
         ylabel="\\Theta_i")

add(p, FillBetween(x, c, x, s))
add(p, Curve(x, c, color="red"))
add(p, Curve(x, s, color="blue"))
display(p)
~~~~~~~~~~~~~


![](figures/winston_sample_4_1.png)\ 

