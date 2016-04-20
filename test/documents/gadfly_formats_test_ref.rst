

.. code-block:: julia
    
    using Gadfly
    x = linspace(0, 2π, 200)
    plot(x=x, y = sin(x), Geom.line)



.. figure:: figures/gadfly_formats_test_sin_fun_1.png
   :width: 15 cm

   sin(x) function.




.. figure:: figures/gadfly_formats_test_2_1.png
   :width: 15 cm

   cos(x) function.




.. image:: figures/gadfly_formats_test_cos2_fun_1.png
   :width: 15 cm




.. code-block:: julia

julia> x = linspace(0, 2π, 200)

linspace(0.0,6.283185307179586,200)
julia> plot(x=x, y = sin(x), Geom.line)




.. image:: figures/gadfly_formats_test_4_1.png
   :width: 15 cm


.. code-block:: julia

julia> y = 20

20
julia> plot(x=x, y = cos(x), Geom.line)



.. image:: figures/gadfly_formats_test_4_2.png
   :width: 15 cm




.. code-block:: julia
    
    x = linspace(0, 2π, 200)
    plot(x=x, y = sin(x), Geom.line)
    



.. image:: figures/gadfly_formats_test_5_1.png
   :width: 15cm


.. code-block:: julia
    
    y = 20
    plot(x=x, y = cos(x), Geom.line)



.. image:: figures/gadfly_formats_test_5_2.png
   :width: 15cm

