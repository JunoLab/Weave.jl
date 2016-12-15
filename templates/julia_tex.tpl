\documentclass[12pt,a4paper]{article}

\usepackage[a4paper,text={16.5cm,25.2cm},centering]{geometry}
\usepackage{lmodern}
\usepackage{amssymb,amsmath}
\usepackage{mathspec}
\usepackage{graphics}
\usepackage{microtype}
\usepackage{hyperref}

{{#:title}}
\title{ {{{ :title }}} }
{{/:title}}

{{#:author}}
\author{ {{{ :author }}} }
{{/:author}}

{{#:date}}
\date{ {{{ :date }}} }
{{/:date}}

{{{ :highlight }}}

\begin{document}

{{#:title}}\maketitle{{/:title}}

{{{ :body }}}

\end{document}
