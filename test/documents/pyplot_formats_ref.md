````julia
using PyPlot
x = range(0, stop=2π, length=200)
plot(x, sin(x))
````


````
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7fbd590d7860>
````


![sin(x) function.](figures/pyplot_formats_sin_fun_1.png)

````
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7fbd60094160>
````


![cos(x) function.](figures/pyplot_formats_2_1.png)

````
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7fbd5905c7b8>
````


![](figures/pyplot_formats_cos2_fun_1.png)

````julia
julia> x = range(0, stop=2π, length=200)
200-element LinSpace{Float64}:
 0.0,0.0315738,0.0631476,0.0947214,0.126295,…,6.18846,6.22004,6.25161,6.28319

julia> plot(x, sin(x))
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7fbd60047fd0>

julia> y = 20
20

julia> plot(x, cos(x))
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7fbd6004eeb8>

````


![](figures/pyplot_formats_4_1.png)

````julia
x = randn(100, 100)
contourf(x)
````


````
PyObject <matplotlib.contour.QuadContourSet object at 0x7fbd5a506128>
````


![](figures/pyplot_formats_5_1.png)
