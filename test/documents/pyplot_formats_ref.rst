



.. code-block:: julia
    
    using PyPlot
    x = linspace(0, 2π, 200)
    plot(x, sin(x))



::
    
    1-element Array{Any,1}:
     PyObject <matplotlib.lines.Line2D object at 0x7f9745111450>



.. figure:: figures/pyplot_formats_sin_fun_1.svg
   :width: 15 cm

   sin(x) function.




::
    
    1-element Array{Any,1}:
     PyObject <matplotlib.lines.Line2D object at 0x7f9777e49990>



.. figure:: figures/pyplot_formats_2_1.svg
   :width: 15 cm

   cos(x) function.




::
    
    1-element Array{Any,1}:
     PyObject <matplotlib.lines.Line2D object at 0x7f9777d7b590>



.. image:: figures/pyplot_formats_cos2_fun_1.svg
   :width: 15 cm




.. code-block:: julia

julia> x = linspace(0, 2π, 200)

linspace(0.0,6.283185307179586,200)
julia> plot(x, sin(x))

1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7f9777c71190>
julia> y = 20

20
julia> plot(x, cos(x))
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7f9777c71390>



.. image:: figures/pyplot_formats_4_1.svg
   :width: 15 cm




.. code-block:: julia
    
    x = randn(100, 100)
    contourf(x)



::
    
    PyObject <matplotlib.contour.QuadContourSet object at 0x7f9777ba3510>



.. image:: figures/pyplot_formats_5_1.svg
   :width: 15cm

