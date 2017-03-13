.. code-block:: julia
    
    using PyPlot
    x = linspace(0, 2π, 200)
    plot(x, sin(x))
    


::
    
    1-element Array{Any,1}:
     PyObject <matplotlib.lines.Line2D object at 0x7fbd50edb0b8>



.. figure:: figures/pyplot_formats_sin_fun_1.svg
   :width: 15 cm

   sin(x) function.


::
    
    1-element Array{Any,1}:
     PyObject <matplotlib.lines.Line2D object at 0x7fbd514a7780>



.. figure:: figures/pyplot_formats_2_1.svg
   :width: 15 cm

   cos(x) function.


::
    
    1-element Array{Any,1}:
     PyObject <matplotlib.lines.Line2D object at 0x7fbd580c6080>



.. image:: figures/pyplot_formats_cos2_fun_1.svg
   :width: 15 cm


.. code-block:: julia

julia> x = linspace(0, 2π, 200)
200-element LinSpace{Float64}:
 0.0,0.0315738,0.0631476,0.0947214,0.126295,…,6.18846,6.22004,6.25161,6.28319

julia> plot(x, sin(x))
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7fbd585a7320>

julia> y = 20
20

julia> plot(x, cos(x))
1-element Array{Any,1}:
 PyObject <matplotlib.lines.Line2D object at 0x7fbd58612128>




.. image:: figures/pyplot_formats_4_1.svg
   :width: 15 cm


.. code-block:: julia
    
    x = randn(100, 100)
    contourf(x)
    


::
    
    PyObject <matplotlib.contour.QuadContourSet object at 0x7fbd5a2d8e48>



.. image:: figures/pyplot_formats_5_1.svg
   :width: 15cm

