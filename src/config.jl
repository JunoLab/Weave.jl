

#Default options
const defaultParams =
    @compat Dict{Symbol,Any}(:plotlib => "Gadfly",
                            :storeresults => false,
                            :doc_number => 0,
                            :chunk_defaults =>
                                Dict{Symbol,Any}(
                                :echo=> true,
                                :results=> "markup",
                                :hold => false,
                                :fig=> true,
                                :include=> true,
                                :eval => true,
                                :tangle => true,
                                :cache => false,
                                :fig_cap=> nothing,
                                #Size in inches
                                :fig_width => 6,
                                :fig_height => 4,
                                :fig_path=> "figures",
                                :dpi => 96,
                                :term=> false,
                                :display => false,
                                :prompt => "\njulia> ",
                                :name=> nothing,
                                :wrap=> true,
                                :line_width => 75,
                                :engine=> "julia",
                                #:option_AbstractString=> "",
                                #Defined in formats
                                :fig_ext => nothing,
                                :fig_pos=> nothing,
                                :fig_env=> nothing,
                                :out_width=> nothing,
                                :out_height=> nothing,
                                )
                            )
#This one can be changed at runtime, initially a copy of defaults
const rcParams = deepcopy(defaultParams)

#Parameters set per document
const docParams =Dict{Symbol,Any}(
                                :fig_path=> nothing,
                                :fig_ext => nothing,
                            )




"""
`set_chunk_defaults(opts::Dict{Symbol, Any})`

Set default options for code chunks, use get_chunk_defaults
to see the current values.

e.g. set default dpi to 200 and fig_width to 8

```
julia> set_chunk_defaults(Dict{Symbol, Any}(:dpi => 200, fig_width => 8))
```
"""
function set_chunk_defaults(opts::Dict{Symbol, Any})
  merge!(rcParams[:chunk_defaults], opts)
  return nothing
end

"""
`get_chunk_defaults()`

Get default options used for code chunks.
"""
function get_chunk_defaults()
  return(rcParams[:chunk_defaults])
end

"""
`restore_chunk_defaults()`

Restore Weave.jl default chunk options
"""
function restore_chunk_defaults()
  rcParams[:chunk_defaults] = defaultParams[:chunk_defaults]
  merge!(rcParams[:chunk_defaults], docParams)
  return nothing
end
