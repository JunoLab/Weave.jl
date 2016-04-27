
.. code-block:: julia

julia> using Winston

julia> t = linspace(0, 2*pi, 100)

linspace(0.0,6.283185307179587,100)
julia> plot(t, sinc(t))

Winston.FramedPlot(...)



.. image:: figures/winston_formats_1_1.png
   :width: 15 cm


.. code-block:: julia

julia> s = 1:10

1:10
julia> plot(s, "r*")
Winston.FramedPlot(...)



.. image:: figures/winston_formats_1_2.png
   :width: 15 cm






.. figure:: figures/winston_formats_random_1.png
   :width: 15 cm

   Random walk.





.. code-block:: julia
    
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
    



::
    
    warning: sub-optimal solution for plot



.. image:: figures/winston_formats_3_1.png
   :width: 15 cm


.. code-block:: julia
    
    
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



.. image:: figures/winston_formats_3_2.png
   :width: 15 cm

