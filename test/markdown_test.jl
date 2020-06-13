# TODO: make this more sensible:
# - separate tests for
#   1. features that are "copy-and-pasted" from `Markdown` module
#   2. features that are extended by Weave

using Weave: WeaveMarkdown, Markdown

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

head 1 | head 2
-------|--------
`code` | no code

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
<table><tr><th>head 1</th><th>head 2</th></tr><tr><td><code>code</code></td><td>no code</td></tr></table>
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
