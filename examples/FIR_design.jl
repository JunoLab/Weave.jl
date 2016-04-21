#' % FIR filter design with Julia
#' % Matti Pastell
#' % 21th April 2016

#' # Introduction

#' This an example of a julia script that can be published using
#' [Weave](http://mpastell.github.io/Weave.jl/latest/usage/).
#' The script can be executed normally using Julia
#' or published to HTML or pdf with Weave.
#' Text is written in markdown in lines starting with "`#'` " and code
#' is executed and results are included in the published document.

#' Notice that you don't need to define chunk options, but you can using
#' `#+`. just before code e.g. `#+ term=True, caption='Fancy plots.'`.
#' If you're viewing the published version have a look at the
#' [source](FIR_design.jl) to see the markup.


#' # FIR Filter Design

#' We'll implement lowpass, highpass and ' bandpass FIR filters. If
#' you want to read more about DSP I highly recommend [The Scientist
#' and Engineer's Guide to Digital Signal
#' Processing](http://www.dspguide.com/) which is freely available
#' online.

#' ## Functions for frequency, phase, impulse and step response

#' Let's first define functions to plot filter
#' properties.

using Gadfly, DSP

plot(x=1:10)

#' ## Lowpass FIR filter

#' Designing a lowpass FIR filter is very simple to do with SciPy, all you
#' need to do is to define the window length, cut off frequency and the
#' window.

#' The Hamming window is defined as:
#' $w(n) = \alpha - \beta\cos\frac{2\pi n}{N-1}$, where $\alpha=0.54$ and $\beta=0.46$

#' The next code chunk is executed in term mode, see the [Python script](FIR_design.py) for syntax.
#' Notice also that Pweave can now catch multiple figures/code chunk.

#+ term=true
n = 61



#' ## Highpass FIR Filter

#' Let's define a highpass FIR filter, if you compare to original blog
#' post you'll notice that it has become easier since 2009. You don't
#' need to do ' spectral inversion "manually" anymore!

n = 101

#' ## Bandpass FIR filter

#' Notice that the plot has a caption defined in code chunk options.

#+ caption = "Bandpass FIR filter."

n = 1001
