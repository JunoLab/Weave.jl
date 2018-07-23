
using Plots
pyplot()
x = range(0, stop=2*pi, length=50)
println(x)
p = plot(x = x, y = sin(x), size =(900,300))

plot(x = x, y = sin(x))

plot(rand(100) / 3,reg=true,fill=(0,:green))
scatter!(rand(100),markersize=6,c=:orange)

plot(rand(100) / 3,reg=true,fill=(0,:green))
scatter!(rand(100),markersize=6,c=:orange)

plot(y = cumsum(randn(1000, 1)))
