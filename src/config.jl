# Default options
const _CHUNK_DEFAULTS = Ref(Dict{Symbol,Any}(
    :echo => true,
    :results => "markup",
    :hold => false,
    :fig => true,
    :include => true,
    :eval => true,
    :tangle => true,
    :cache => false,
    :fig_cap => nothing,
    # NOTE: size in inches
    :fig_width => 6,
    :fig_height => 4,
    :fig_path => DEFAULT_FIG_PATH,
    :dpi => 96,
    :term => false,
    :prompt => "julia> ",
    :label => nothing,
    :wrap => true,
    :line_width => 75,
    :engine => "julia",
    :fig_ext => nothing,
    :fig_pos => nothing,
    :fig_env => nothing,
    :out_width => nothing,
    :out_height => nothing,
    :skip => false,
))

const CHUNK_DEFAULTS = Ref(deepcopy(_CHUNK_DEFAULTS[]))

"""
    set_chunk_defaults!(key::Symbol, val)
    set_chunk_defaults!(kvs::Pair...)
    set_chunk_defaults!(opts::Dict{Symbol,Any})

Set default options for code chunks, use [`get_chunk_defaults`](@ref) to see the current values.

E.g.: set default `dpi` to `200` and `fig_width` to `8` (all of the three ways below are equivalent):
- `set_chunk_defaults!(:dpi, 200); set_chunk_defaults!(:fig_width, 8)`
- `set_chunk_defaults!(:dpi => 200, :fig_width => 8)`
- `set_chunk_defaults!(Dict(:dpi => 200, :fig_width => 8))`
"""
set_chunk_defaults!(key::Symbol, val) = CHUNK_DEFAULTS[][key] = val
set_chunk_defaults!(kvs::Pair...) = for (k,v) in kvs; CHUNK_DEFAULTS[][k] = v; end
set_chunk_defaults!(opts::Dict{Symbol,Any}) = merge!(CHUNK_DEFAULTS[], opts)

"""
    get_chunk_defaults()

Get default options used for code chunks.
"""
get_chunk_defaults() = CHUNK_DEFAULTS[]

"""
    restore_chunk_defaults!()

Restore Weave.jl default chunk options.
"""
restore_chunk_defaults!() = CHUNK_DEFAULTS[] = deepcopy(_CHUNK_DEFAULTS[])
