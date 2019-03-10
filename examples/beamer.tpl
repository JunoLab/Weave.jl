\documentclass{beamer}

\usepackage{lmodern}
\usepackage{amssymb,amsmath}
\usepackage{bm}
\usepackage{graphicx}
\usepackage{microtype}
\usepackage{hyperref}
\setlength{\parindent}{0pt}
\setlength{\parskip}{1.2ex}

\hypersetup
       {   pdfauthor = { {{{:author}}} },
           pdftitle={ {{{:title}}} },
           colorlinks=TRUE,
           linkcolor=black,
           citecolor=blue,
           urlcolor=blue
       }


{{#:title}}
\title{ {{{ :title }}} }
{{/:title}}

{{#:author}}
\author{ {{{ :author }}} }
{{/:author}}

{{#:date}}
\date{ {{{ :date }}} }
{{/:date}}

{{ :highlight }}

\begin{document}

{{{#:title}}}
\begin{frame}
\titlepage
\end{frame}
{{{/:title}}}

{{{ :body }}}

\end{document}
