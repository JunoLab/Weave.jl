
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





# Prompt

~~~~{.julia}
julietta> using Gadfly

julietta> x = 1:10
1:10

julietta> plot(x = x, y = x)

~~~~~~~~~~~~~


![](figures/test_hold_3_1.png)\ 


~~~~{.julia}
julietta> print(x)
1:10
julietta> plot(x = x, y = x)

~~~~~~~~~~~~~


![](figures/test_hold_3_2.png)\ 


~~~~{.julia}
julietta> display(x)
1:10

~~~~~~~~~~~~~





# Display

~~~~{.julia}
using Gadfly
x = 1:10
~~~~~~~~~~~~~


~~~~
1:10
~~~~



~~~~{.julia}
plot(x = x, y = x)
~~~~~~~~~~~~~


![](figures/test_hold_4_1.png)\ 


~~~~{.julia}
print(x)
~~~~~~~~~~~~~


~~~~
1:10
~~~~



~~~~{.julia}
plot(x = x, y = x)
~~~~~~~~~~~~~


![](figures/test_hold_4_2.png)\ 


~~~~{.julia}
display(x)
~~~~~~~~~~~~~


~~~~
1:10
~~~~





# Both display and term

~~~~{.julia}
julia> using Gadfly

julia> x = 1:10
1:10

julia> plot(x = x, y = x)

~~~~~~~~~~~~~


![](figures/test_hold_5_1.png)\ 


~~~~{.julia}
julia> print(x)
1:10
julia> plot(x = x, y = x)

~~~~~~~~~~~~~


![](figures/test_hold_5_2.png)\ 


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
1:101:10
~~~~


![](figures/test_hold_6_1.png)\ 

![](figures/test_hold_6_2.png)\ 

