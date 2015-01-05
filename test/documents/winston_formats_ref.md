

````julia
julia> using Winston

julia> t = linspace(0, 2*pi, 100)
100-element Array{Float64,1}:
 0.0      
 0.0634665
 0.126933 
 0.1904   
 0.253866 
 0.317333 
 0.380799 
 0.444266 
 0.507732 
 0.571199 
 ⋮        
 5.77545  
 5.83892  
 5.90239  
 5.96585  
 6.02932  
 6.09279  
 6.15625  
 6.21972  
 6.28319  

julia> plot(t, sinc(t))

````


![](figures/winston_formats_1_1.png)

````julia
FramedPlot(...)

````




````julia
julia> s = 1:10
1:10

julia> plot(s, "r*")

````


![](figures/winston_formats_1_2.png)

````julia
FramedPlot(...)

````








![Random walk.](figures/winston_formats_random_1.png)




````julia
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

p = FramedPlot(
     aspect_ratio=1,
     xrange=(0,100),
     yrange=(0,100))

n = 21
x = linspace(0, 100, n)
yA = 40 .+ 10randn(n)
yB = x .+ 5randn(n)

a = Points(x, yA, kind="circle")
setattr(a, label="a points")

b = Points(x, yB)
setattr(b, label="b points")
style(b, kind="filled circle")

s = Slope(1, (0,0), kind="dotted")
setattr(s, label="slope")

l = Legend(.1, .9, {a,b,s})

add(p, s, a, b, l)
display(p)
````


![](figures/winston_formats_3_1.png)
![](figures/winston_formats_3_2.png)
