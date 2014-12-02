const rcParams =
    @compat Dict{Symbol,Any}(:figdir=> "figures",
                             :plotlib => "PyPlot",
                             :storeresults=> false,
                             :cachedir=> "cache",
                             :chunk=>
                             Dict{Symbol,Any}(:defaultoptions=>
                                              Dict{Symbol,Any}(:echo=> true,
                                                               :results=> "verbatim",
                                                               :fig=> true,
                                                               :include=> true,
                                                               :evaluate=> true,
                                                               :caption=> false,
                                                               :term=> false,
                                                               :name=> nothing,
                                                               :wrap=> true,
                                                               :f_pos=> "htpb",
                                                               :f_size=> (8, 6),
                                                               :f_env=> nothing,
                                                               :f_spines=> true,
                                                               :complete=> true,
                                                               :engine=> "julia",
                                                               :option_string=> "")
                                              )
                             )
