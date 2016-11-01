
# Gadfly

````julia
julia> using Gadfly

julia> x = linspace(0, 2π, 200)

200-element LinSpace{Float64}:
 0.0,0.0315738,0.0631476,0.0947214,0.126295,…,6.18846,6.22004,6.25161,6.28319
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

200-element LinSpace{Float64}:
 0.0,0.0315738,0.0631476,0.0947214,0.126295,…,6.18846,6.22004,6.25161,6.28319
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


