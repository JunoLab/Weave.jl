


~~~~{.julia}
using Gadfly
x = linspace(0, 2π, 200)
plot(x=x, y = sin(x), Geom.line)
~~~~~~~~~~~~~


![sin(x) function.](figures/gadfly_formats_test_sin_fun_1.png)



![cos(x) function.](figures/gadfly_formats_test_2_1.png)



![](figures/gadfly_formats_test_cos2_fun_1.png)



~~~~{.julia}
julia> x = linspace(0, 2π, 200)

linspace(0.0,6.283185307179586,200)
julia> plot(x=x, y = sin(x), Geom.line)

~~~~~~~~~~~~~


![](figures/gadfly_formats_test_4_1.png)

~~~~{.julia}
julia> y = 20

20
julia> plot(x=x, y = cos(x), Geom.line)
~~~~~~~~~~~~~


![](figures/gadfly_formats_test_4_2.png)



~~~~{.julia}
x = linspace(0, 2π, 200)
plot(x=x, y = sin(x), Geom.line)

~~~~~~~~~~~~~


![](figures/gadfly_formats_test_5_1.png)

~~~~{.julia}
y = 20
plot(x=x, y = cos(x), Geom.line)
~~~~~~~~~~~~~


![](figures/gadfly_formats_test_5_2.png)
