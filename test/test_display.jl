@testset "limit HMTL output" begin

@static VERSION ≥ v"1.4" && let

# no limit
doc = mock_run("""
```julia
using DataFrames
DataFrame(a=rand(10))
```
"""; doctype = "md2html")
@test isdefined(doc.chunks[1], :rich_output)
@test count("<tr", doc.chunks[1].rich_output) == 12 # additonal 2 for name and type row

# limit
n = 100000
doc = mock_run("""
```julia
using DataFrames
DataFrame(a=rand($n))
```
"""; doctype = "md2html")
@test isdefined(doc.chunks[1], :rich_output)
@test count("<tr>", doc.chunks[1].rich_output) < n

# `displaysize`
rows = 10 # number of rows in table
columns = 10 # number of colums in table

displaysize_rows = 1
displaysize_columns = 1
displayed_rows = displaysize_rows # number of rows that ends up getting displayed
displayed_columns = displaysize_columns # number of columns that ends up getting displayed

doc = mock_run("""
```julia; displaysize=($displaysize_rows, $displaysize_columns)
using DataFrames
DataFrame(Dict(Symbol(i) => rand($(rows)) for i = 1:$(columns)))
```
"""; doctype = "md2html")
@test isdefined(doc.chunks[1], :rich_output)
# Name row: 1
# Type row: 1
# Displayed rows: `displaysize_rows`
# ... row: 1
@test count("<tr>", doc.chunks[1].rich_output) == displayed_rows + 3
# Name row: 1 per displayed column + 1 for index column
# Type row: 1 per displayed column + 1 for index column
# Displayed rows: 1 per row
# ... row: 1
# Mistakenly match `<thead`: 1
@test count("<th", doc.chunks[1].rich_output) == (displayed_columns + 1) * 2 + displayed_rows + 1 + 1

# Increase rows but not columns.
displaysize_rows = 5
displaysize_columns = 1
displayed_rows = displaysize_rows
displayed_columns = displaysize_columns

doc = mock_run("""
```julia; displaysize=($displaysize_rows, $displaysize_columns)
using DataFrames
DataFrame(Dict(Symbol(i) => rand($(rows)) for i = 1:$(columns)))
```
"""; doctype = "md2html")
@test isdefined(doc.chunks[1], :rich_output)
@test count("<tr>", doc.chunks[1].rich_output) == displayed_rows + 3
@test count("<th", doc.chunks[1].rich_output) == (displayed_columns + 1) * 2 + displayed_rows + 1 + 1

# Increase columns too.
displaysize_rows = 5
displaysize_columns = 1000 # enough to get ALL `columns` to be displayed.
displayed_rows = displaysize_rows
displayed_columns = columns # `displaysize_columns` large enough for all columns to be displayed
doc = mock_run("""
```julia; displaysize=($displaysize_rows, $displaysize_columns)
using DataFrames
DataFrame(Dict(Symbol(i) => rand($(rows)) for i = 1:$(columns)))
```
"""; doctype = "md2html")
@test isdefined(doc.chunks[1], :rich_output)
@test count("<tr>", doc.chunks[1].rich_output) == displayed_rows + 3
@test count("<th", doc.chunks[1].rich_output) == (displayed_columns + 1) * 2 + displayed_rows + 1 + 1


end

end
