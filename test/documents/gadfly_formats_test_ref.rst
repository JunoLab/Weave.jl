


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
    200-element Array{Float64,1}:
     0.0      
     0.0315738
     0.0631476
     0.0947214
     0.126295 
     0.157869 
     0.189443 
     0.221017 
     0.25259  
     0.284164 
     ⋮        
     6.03059  
     6.06217  
     6.09374  
     6.12532  
     6.15689  
     6.18846  
     6.22004  
     6.25161  
     6.28319  
    
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
    y = 20
    plot(x=x, y = cos(x), Geom.line)



.. image:: figures/gadfly_formats_test_5_1.png
   :width: 15cm

.. image:: figures/gadfly_formats_test_5_2.png
   :width: 15cm



