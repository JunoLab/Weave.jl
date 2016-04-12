




.. code-block:: julia
    
    using PyPlot
    x = linspace(0, 2π, 200)
    plot(x, sin(x))



.. figure:: figures/pyplot_formats_sin_fun_1.svg
   :width: 15 cm

   sin(x) function.




.. figure:: figures/pyplot_formats_2_1.svg
   :width: 15 cm

   cos(x) function.




.. image:: figures/pyplot_formats_cos2_fun_1.svg
   :width: 15 cm




.. code-block:: julia

julia> x = linspace(0, 2π, 200)

linspace(0.0,6.283185307179586,200)
julia> plot(x, sin(x))

1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7f995cdeae90>
julia> y = 20

20
julia> plot(x, cos(x))
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7f995cdf9b90>



.. image:: figures/pyplot_formats_4_1.svg
   :width: 15 cm




.. code-block:: julia
    
    x = randn(100, 100)
    contourf(x)



.. image:: figures/pyplot_formats_5_1.svg
   :width: 15cm

