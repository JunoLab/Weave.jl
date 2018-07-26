using Test
import Weave: Markdown2HTML
import Markdown

# Test markdown2html writer

html = Markdown2HTML.html(Markdown.parse("""

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

"""))

ref_html = """<h1>H1</h1>
<h2>H2</h2>
<h2>H3</h2>
<p>Some <strong>text</strong> with different <a href=\"#footnote-note\" class=\"footnote\">[note]</a> <em>formatting</em> and <span class=\"math\">\$math\$</span> and text.</p>
<p><code>some code</code> with <a href=\"http://github.com\">link</a></p>
<div class=\"footnote\" id=\"footnote-note\"><p class=\"footnote-title\">note</p><p>test note</p>
</div>
<hr />
<p class=\"math\">\\[more math\\]</p>
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
<pre><code class=\"language-julia\">x &#61; 3 </code></pre>
<div class=\"admonition note\"><p class=\"admonition-title\">Something</p><p>Test admonition with <img src=\"link/to/image.png\" alt=\"Image\" /></p>
</div>
<blockquote>
<p>Some important quote</p>
</blockquote>
"""

@test html == ref_html
