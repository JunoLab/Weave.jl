




````julia
using PyPlot
x = linspace(0, 2π, 200)
plot(x, sin(x))
````


![sin(x) function.](figures/pyplot_formats_sin_fun_1.png)



![cos(x) function.](figures/pyplot_formats_2_1.png)



![](figures/pyplot_formats_cos2_fun_1.png)



````julia
julia> x = linspace(0, 2π, 200)
linspace(0.0,6.283185307179586,200)

julia> plot(x, sin(x))
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7f702c979c10>

julia> y = 20
20

julia> plot(x, cos(x))
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7f702c979e90>

````


![](figures/pyplot_formats_4_1.png)



````julia
x = randn(100, 100)
contourf(x)
````


![](figures/pyplot_formats_5_1.png)
