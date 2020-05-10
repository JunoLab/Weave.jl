# Default options
const defaultParams = Dict{Symbol,Any}(
    :storeresults => false,
    :chunk_defaults => Dict{Symbol,Any}(
        :echo => true,
        :results => "markup",
        :hold => false,
        :fig => true,
        :include => true,
        :eval => true,
        :tangle => true,
        :cache => false,
        :fig_cap => nothing,
        # Size in inches
        :fig_width => 6,
        :fig_height => 4,
        :fig_path => "figures",
        :dpi => 96,
        :term => false,
        :display => false,
        :prompt => "\njulia> ",
        :label => nothing,
        :wrap => true,
        :line_width => 75,
        :engine => "julia",
        # :option_AbstractString=> "",
        # Defined in formats
        :fig_ext => nothing,
        :fig_pos => nothing,
        :fig_env => nothing,
        :out_width => nothing,
        :out_height => nothing,
        :skip => false,
    ),
)
# This one can be changed at runtime, initially a copy of defaults
const rcParams = deepcopy(defaultParams)

"""
    set_chunk_defaults!(opts::Dict{Symbol, Any})

Set default options for code chunks, use [`get_chunk_defaults`](@ref) to see the current values.

E.g.: set default `dpi` to `200` and `fig_width` to `8`

```julia
julia> set_chunk_defaults!(Dict(:dpi => 200, :fig_width => 8))
```
"""
set_chunk_defaults!(opts::Dict{Symbol,Any}) = merge!(rcParams[:chunk_defaults], opts)

"""
    get_chunk_defaults()

Get default options used for code chunks.
"""
get_chunk_defaults() = rcParams[:chunk_defaults]

"""
    restore_chunk_defaults!()

Restore Weave.jl default chunk options.
"""
restore_chunk_defaults!() = rcParams[:chunk_defaults] = defaultParams[:chunk_defaults]

"""Combine format specific and common options from document header"""
function combine_args(args, doctype)
    common = Dict()
    specific = Dict()
    for key in keys(args)
        if key in keys(Weave.formats)
            specific[key] = args[key]
        else
            common[key] = args[key]
        end
    end
    haskey(specific, doctype) && merge!(common, specific[doctype])
    common
end
