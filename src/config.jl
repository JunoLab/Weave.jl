
const rcParams =
    @compat Dict{Symbol,Any}(:plotlib => "PyPlot",
                            :storeresults => false,
                            :doc_number => 0,
                            :chunk_defaults =>
                                Dict{Symbol,Any}(
                                :echo=> true,
                                :results=> "markup",
                                :fig=> true,
                                :include=> true,
                                :eval => true,
                                :fig_cap=> nothing,
                                #Size in inches
                                :fig_width => 6,
                                :fig_height => 4,
                                :fig_path=> "figures",
                                :dpi => 96,
                                :term=> false,
                                :name=> nothing,
                                :wrap=> true,
                                :line_width => 75,
                                :engine=> "julia",
                                #:option_string=> "",
                                #Defined in formats
                                :fig_ext => nothing,
                                :fig_pos=> nothing,
                                :fig_env=> nothing,
                                :out_width=> nothing,
                                :out_height=> nothing,
                                )
                            )





# Working towards Knitr compatible options, implemented options are
# added to defaultoptions dictionary above and work in progress stays here,
# options from https://github.com/yihui/knitr/blob/master/R/defaults.R
# If you need a particular options, consider implementing it and making a
# pull request.

#tidy = FALSE,
#tidy.opts = NULL,
#collapse = FALSE
#prompt = FALSE
#highlight = TRUE
#strip.white = TRUE
#size = 'normalsize'
#background = '#F7F7F7',
#cache = FALSE
#cache.path = 'cache/'
#cache.vars = NULL
#cache.lazy = TRUE,
#dependson = NULL
#autodep = FALSE,
#fig.keep = 'high'
#fig.show = 'asis'
#fig.align = 'default'
#dev = NULL
#dev.args = NULL
#fig.ext = NULL
#fig.scap = NULL
#fig.lp = 'fig:'
#fig.subcap = NULL,
#out.extra = NULL
#fig.retina = 1,
#external = TRUE
#sanitize = FALSE
#interval = 1
#aniopts = 'controls,loop',
#warning = TRUE
#error = TRUE
#message = TRUE,
#render = NULL,
#ref.label = NULL
#child = NULL
#split = FALSE
#purl = TRUE
