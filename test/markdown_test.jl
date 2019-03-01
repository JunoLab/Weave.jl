using Test
import Weave: WeaveMarkdown
import Markdown

# Test markdown2html writer

html = WeaveMarkdown.html(Markdown.parse("""

# H1

## H2

## H3


Some **text** with different [^note] *formatting* and \$math\$ and text.

`some code` with [link](http://github.com)

[^note]: test note

---

\$more math\$

* List one
* List two

1. List one
2. List two

```julia
x = 3
```

!!! note "Something"

    Test admonition with ![Image](link/to/image.png)

> Some important quote

""", flavor = WeaveMarkdown.weavemd))

ref_html = """<h1>H1</h1>
<h2>H2</h2>
<h2>H3</h2>
<p>Some <strong>text</strong> with different <a href=\"#footnote-note\" class=\"footnote\">[note]</a> <em>formatting</em> and <span class=\"math\">\$math\$</span> and text.</p>
<p><code>some code</code> with <a href=\"http://github.com\">link</a></p>
<div class=\"footnote\" id=\"footnote-note\"><p class=\"footnote-title\">note</p><p>test note</p>
</div>
<hr />
<p class=\"math\">\\[
more math
\\]</p>
<ul>
<li><p>List one</p>
</li>
<li><p>List two</p>
</li>
</ul>
<ol>
<li><p>List one</p>
</li>
<li><p>List two</p>
</li>
</ol>
<pre><code class=\"language-julia\">x &#61; 3</code></pre>
<div class=\"admonition note\"><p class=\"admonition-title\">Something</p><p>Test admonition with <img src=\"link/to/image.png\" alt=\"Image\" /></p>
</div>
<blockquote>
<p>Some important quote</p>
</blockquote>
"""

@test html == ref_html

#Test Weave additions
md = Markdown.parse("""

Multiline equations

\$\$
x = 2
\$\$

And comments <!-- inline -->

<!--
Multiple lines
 -->
""", flavor = WeaveMarkdown.weavemd);

@test md.content[2].formula  == "x = 2"
@test typeof(md.content[3].content[2]) == WeaveMarkdown.Comment
@test md.content[3].content[2].text == " inline "
@test md.content[4].text == "\nMultiple lines\n "

@test WeaveMarkdown.latex(md.content[2]) == "\\[\nx = 2\n\\]\n"
@test WeaveMarkdown.latex(md.content[4]) == "% \n% Multiple lines\n%  \n"

@test WeaveMarkdown.html(md.content[2]) == "<p class=\"math\">\\[\nx = 2\n\\]</p>"
@test WeaveMarkdown.html(md.content[4]) == "\n<!-- \nMultiple lines\n  -->\n"

##
using Revise
import Weave: WeaveMarkdown
import Mustache

md = """

[@Bezanson2017]

citing [@pastell_filtering_2018; @someref]

cite [@Bezanson2017] again

"""

m = WeaveMarkdown.parse_markdown(md, joinpath(@__DIR__, "documents/bibtex/testdocs.bib"));
m
# Render references
tpl = Mustache.template_from_file(joinpath(@__DIR__, "../templates/html_citations.tpl"))
ref = WeaveMarkdown.CITATIONS[:references]["Bezanson2017"]
ref[ref["type"]] = "true"
ref["author"] = replace(ref["author"], r"\sand\s"i => ", ")
for key in keys(ref)
    ref[key] = replace(ref[key], r"\{|\}" => "")
    ref[key] = replace(ref[key], "--" => "&mdash;")
end

Mustache.render(tpl, ref)
r2 = Dict("author" => "Matti Pastell", "title" => "Some paper", "article" => "true")
Mustache.render(tpl, r2)
