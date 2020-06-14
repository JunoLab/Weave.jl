using Weave.Dates


test_doctypes = filter(first.(Weave.list_out_formats())) do doctype
    # don't test doctypes which need external programs
    doctype ∉ ("pandoc2html", "pandoc2pdf", "md2pdf")
end

function test_func(body)
    @test !isempty(body)
    date_str = string(Date(now()))
    @test occursin(date_str, body)
end

# julia markdown
julia_markdown_body = """
# doc chunk

this is text with `j :inline` code

code chunk:
```julia
using Dates
Date(now())
```
"""

for doctype in test_doctypes
    test_mock_weave(test_func, julia_markdown_body; informat = "markdown", doctype = doctype)
end

# TODO: test noweb format

# julia script
julia_script_body = """
#' # doc chunk
#'
#' this is text with `j :inline` code
#'
#' code chunk:
#+

using Dates
Date(now())
"""
for doctype in test_doctypes
    test_mock_weave(test_func, julia_script_body; informat = "script", doctype = doctype)
end
