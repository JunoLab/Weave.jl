
# Gadfly

````julia
julia> using Gadfly

julia> x = linspace(0, 2π, 200)

linspace(0.0,6.283185307179586,200)
julia> plot(x=x, y = sin(x), Geom.line)

````


![](figures/gadfly_markdown_test_1_1.png)

````julia
julia> y = 20

20
julia> plot(x=x, y = cos(x), Geom.line)
````


![](figures/gadfly_markdown_test_1_2.png)




````julia
x = linspace(0, 200)
println(x)
````


````
linspace(0.0,200.0,50)
````






````julia
julia> using Gadfly

julia> x = linspace(0, 2π, 200)

linspace(0.0,6.283185307179586,200)
julia> plot(x=x, y = sin(x), Geom.line)

````


![](figures/gadfly_markdown_test_3_1.png)

````julia
julia> y = 20

20
julia> plot(x=x, y = cos(x), Geom.line)
````


![](figures/gadfly_markdown_test_3_2.png)



````julia
x = linspace(0, 200)
println(x)
````


````
linspace(0.0,200.0,50)
````


