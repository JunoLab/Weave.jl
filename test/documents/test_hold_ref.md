
# Default

~~~~{.julia}
using Gadfly
x = 1:10
plot(x = x, y = x)

~~~~~~~~~~~~~


![](figures/test_hold_1_1.png)\ 


~~~~{.julia}
print(x)

~~~~~~~~~~~~~


~~~~
1:10
~~~~



~~~~{.julia}
plot(x = x, y = x)

~~~~~~~~~~~~~


![](figures/test_hold_1_2.png)\ 


~~~~{.julia}
display(x)
~~~~~~~~~~~~~


~~~~
1:10
~~~~





# Terminal

~~~~{.julia}
julia> using Gadfly

julia> x = 1:10

1:10
julia> plot(x = x, y = x)

~~~~~~~~~~~~~


![](figures/test_hold_2_1.png)\ 


~~~~{.julia}
julia> print(x)
1:10
julia> plot(x = x, y = x)

~~~~~~~~~~~~~


![](figures/test_hold_2_2.png)\ 


~~~~{.julia}
julia> display(x)
1:10
~~~~~~~~~~~~~





# Hold results

~~~~{.julia}
using Gadfly
x = 1:10
plot(x = x, y = x)
print(x)
plot(x = x, y = x)
display(x)
~~~~~~~~~~~~~


~~~~
1:10
1:10
~~~~


![](figures/test_hold_3_1.png)\ 

![](figures/test_hold_3_2.png)\ 

