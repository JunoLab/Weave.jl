using Weave: separate_header_text, parse_header, specific_options!

# TODO: add test for header restoring (strip)

@testset "header separation" begin

header_body = """
weave_options:
    foo: bar
"""

let
    header_text = "---\n$header_body---"
    f, l = separate_header_text("$header_text")
    @test occursin(header_body, f)
    @test isempty(l)
end

let
    doc_body = "hogehoge"
    header_text = "---\n$header_body---\n$doc_body"
    f, l = separate_header_text("$header_text")
    @test occursin(header_body, f)
    @test occursin(doc_body, l)
end

let
    slide_body = """
    ---
    slide comes here !
    ---
    """
    header_text = "---\n$header_body---\n$slide_body"
    f, l = separate_header_text("$header_text")
    @test occursin(header_body, f)
    @test occursin(slide_body, l)
end

end


@testset "empty header" begin
    str = """
    ---
    weave_options:
    ---
    """
    @test (mock_run(str); true) # no throw
end


@testset "dynamic header specifications" begin

let
    d = mock_run("""
    ---
    title: No. `j 1`
    ---
    """)
    @test d.header["title"] == "No. 1"
end

let
    m = Core.eval(Main, :(module $(gensym(:WeaveTest)) end))

    # run in target module
    @eval m n = 1
    d = mock_run("""
    ---
    title: No. `j n`
    ---
    """; mod = m)
    @test d.header["title"] == "No. 1"

    # strip quotes by default
    @eval m s = "1"
    d = mock_run("""
    ---
    title: No. `j s`
    ---
    """; mod = m)
    @test d.header["title"] == "No. 1" # otherwise `"No. "1""`
end

end


@testset "doctype specific header configuration" begin

header = parse_header("""
---
weave_options:
    out_path: reports # should be overwrote
    md2html:
        out_path : html/
    md2pdf:
        out_path : pdf/
    github:
        out_path : md/
    fig_ext : .png    # should remain
---
""")

weave_options = header[Weave.WEAVE_OPTION_NAME]

let md2html_options = copy(weave_options)
    specific_options!(md2html_options, "md2html")
    @test md2html_options == Dict("fig_ext" => ".png", "out_path" => "html/")
end

let md2pdf_options = copy(weave_options)
    specific_options!(md2pdf_options, "md2pdf")
    @test md2pdf_options == Dict("fig_ext" => ".png", "out_path" => "pdf/")
end

let github_options = copy(weave_options)
    specific_options!(github_options, "github")
    @test github_options == Dict("fig_ext" => ".png", "out_path" => "md/")
end

end


@testset "end to end test" begin

# preserve header
test_mock_weave("""
---
key: value
---

find_me
"""; informat = "markdown", doctype = "github") do body
    @test occursin("key: \"value\"", body)
    @test occursin("find_me", body)
end

# only strips weave specific header
test_mock_weave("""
---
key: value
weave_options:
    doctype: github
---

find_me
"""; informat = "markdown", doctype = "github") do body
    @test occursin("key: \"value\"", body)
    @test !occursin("weave_options", body)
    @test occursin("find_me", body)
end

# don't preserve header
test_mock_weave("""
---
weave_options:
    doctype: md2html
---

find_me
"""; informat = "markdown", doctype = "md2html") do body
    @test !occursin("weave_options", body)
    @test occursin("find_me", body)
end

end
