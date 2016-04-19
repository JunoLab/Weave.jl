


~~~~{.julia}
using Gadfly
x = linspace(0, 2π, 200)
plot(x=x, y = sin(x), Geom.line)
~~~~~~~~~~~~~


![sin(x) function.](figures/gadfly_formats_test_sin_fun_1.svg)



![cos(x) function.](figures/gadfly_formats_test_2_1.svg)



![](figures/gadfly_formats_test_cos2_fun_1.svg)\ 




~~~~{.julia}
julia> x = linspace(0, 2π, 200)

linspace(0.0,6.283185307179586,200)
julia> plot(x=x, y = sin(x), Geom.line)

~~~~~~~~~~~~~


![](figures/gadfly_formats_test_4_1.svg)\ 


~~~~{.julia}
julia> y = 20

20
julia> plot(x=x, y = cos(x), Geom.line)
~~~~~~~~~~~~~


![](figures/gadfly_formats_test_4_2.svg)\ 




~~~~{.julia}
x = linspace(0, 2π, 200)
plot(x=x, y = sin(x), Geom.line)

~~~~~~~~~~~~~


![](figures/gadfly_formats_test_5_1.svg)\ 


~~~~{.julia}
y = 20
plot(x=x, y = cos(x), Geom.line)
~~~~~~~~~~~~~


![](figures/gadfly_formats_test_5_2.svg)\ 

