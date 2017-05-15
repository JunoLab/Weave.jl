````julia
using Gadfly
x = linspace(0, 2π, 200)
plot(x=x, y = sin(x), Geom.line)
````


![sin(x) function.](figures/gadfly_formats_test_sin_fun_1.js.svg)

![cos(x) function.](figures/gadfly_formats_test_2_1.js.svg)

![](figures/gadfly_formats_test_cos2_fun_1.js.svg)

````julia
julia> x = linspace(0, 2π, 200)
200-element LinSpace{Float64}:
 0.0,0.0315738,0.0631476,0.0947214,0.126295,…,6.18846,6.22004,6.25161,6.28319

julia> plot(x=x, y = sin(x), Geom.line)
Plot(...)

````


![](figures/gadfly_formats_test_4_1.js.svg)

````julia
julia> y = 20
20

julia> plot(x=x, y = cos(x), Geom.line)
Plot(...)

````


![](figures/gadfly_formats_test_4_2.js.svg)

````julia
x = linspace(0, 2π, 200)
plot(x=x, y = sin(x), Geom.line)
````


![](figures/gadfly_formats_test_5_1.js.svg)

````julia
y = 20
plot(x=x, y = cos(x), Geom.line)
````


![](figures/gadfly_formats_test_5_2.js.svg)
