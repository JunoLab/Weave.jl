# TODO: follow RMarkdown convention more
const _DEFAULT_PARAMS = Dict{Symbol,Any}(
    :echo => true,
    :results => "markup",
    :hold => false,
    :fig => true,
    :eval => true,
    :error => true,
    :tangle => true,
    :cache => false,
    :fig_cap => nothing,
    # NOTE: size in inches
    :fig_width => 6,
    :fig_height => 4,
    :fig_path => DEFAULT_FIG_PATH,
    :dpi => 96,
    :term => false,
    :prompt => "julia>",
    :label => nothing,
    :wrap => false,
    :line_width => 75,
    :displaysize => displaysize(),
    :fig_ext => nothing,
    :fig_pos => nothing,
    :fig_env => nothing,
    :out_width => nothing,
    :out_height => nothing,
)
const DEFAULT_PARAMS = deepcopy(_DEFAULT_PARAMS) # might be changed at runtime

"""
    set_chunk_defaults!(k, v)
    set_chunk_defaults!(kv::Pair...)
    set_chunk_defaults!(opts::AbstractDict)

Set default options for code chunks, use [`get_chunk_defaults`](@ref) to see the current values.

E.g.: all the three examples below will set default `dpi` to `200` and `fig_width` to `8`:
- `set_chunk_defaults!(:dpi, 200); set_chunk_defaults!(:fig_width, 8)`
- `set_chunk_defaults!(:dpi => 200, :fig_width => 8)`
- `set_chunk_defaults!(Dict(:dpi => 200, :fig_width => 8))`
"""
set_chunk_defaults!(k, v) = DEFAULT_PARAMS[k]= v
set_chunk_defaults!(kv::Pair...) = for (k,v) in kv; set_chunk_defaults!(k, v); end
set_chunk_defaults!(opts::AbstractDict) = merge!(DEFAULT_PARAMS, opts)

"""
    get_chunk_defaults()

Get default options used for code chunks.
"""
get_chunk_defaults() = DEFAULT_PARAMS

"""
    restore_chunk_defaults!()

Restore Weave.jl default chunk options.
"""
restore_chunk_defaults!() = for (k,v) in _DEFAULT_PARAMS; DEFAULT_PARAMS[k] = v; end
