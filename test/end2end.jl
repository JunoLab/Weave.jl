# NOTE
# this file keeps old end2end tests, which are very fragile
# - they are being gradually replaced with unit tests, that are much more maintainable and
#   much more helpful for detecting bugs
# - the purpose of this file is to temporarily keep the old end2end tests in a way that
#   they're allowed to fail

tpl = mt"""
{{{ :body }}}
"""

out = weave(joinpath(@__DIR__, "documents", "markdown_beamer.jmd"), doctype="md2html", template=tpl)
@test read(out, String) == read(out*".ref", String)
rm(out)

out = weave(joinpath(@__DIR__, "documents", "markdown_beamer.jmd"), doctype="md2tex", template=tpl)
@test read(out, String) == read(out*".ref", String)
rm(out)
