\ProvidesClass{manual}

\LoadClass{article}
\RequirePackage[letterpaper, margin=1in]{geometry} % 1 inch margins required

% text
\RequirePackage[utf8]{inputenc}
\setlength\parindent{0pt}
\setlength{\parskip}{1em}
\renewcommand{\familydefault}{\sfdefault}
\RequirePackage{setspace}

% force all floats to center (see https://tex.stackexchange.com/a/53383)
\makeatletter
\g@addto@macro\@floatboxreset{\centering}
\makeatother

% each section is a new page
\let\stdsection\section
\renewcommand\section{\clearpage\stdsection}

% hyperref
\RequirePackage[colorlinks=true, linkcolor=black, urlcolor=blue, citecolor=black,
anchorcolor=black]{hyperref}

% images
\RequirePackage{graphicx}
\RequirePackage{pdfpages}


\usepackage{array}
\newcolumntype{P}[1]{>{\raggedleft\arraybackslash}p{#1}}

\RequirePackage[shortlabels]{enumitem}
\setlist[itemize, 1]{nosep}
\setlist[itemize, 2]{nosep, topsep=-5ex}
\setlist[itemize, 3]{nosep, topsep=-5ex}
\setlist[itemize, 4]{nosep, topsep=-5ex}
\newenvironment{ditemize}
  {
  \begin{itemize}
  \renewcommand{\labelitemi}{$\rightarrow$}
  \singlespacing
  }
  {
  \end{itemize}
  }



% --- code environment ----------------------------------------------------------------------------

\RequirePackage{etoolbox}
\RequirePackage{pmboxdraw}  % for box drawing charachters
\RequirePackage[section]{minted}
\usemintedstyle{default}
\setminted[python]{linenos=false, frame=none}

\definecolor{bg}{rgb}{0.95, 0.95, 0.95}

\RequirePackage[many]{tcolorbox}
\tcbuselibrary{minted}

%\tcbset{step={\refstepcounter{equation}}}

\NewTCBListing[number within=chapter, auto counter]{codefragment}{mo}{%
  colback=bg,
  boxrule=1pt,
  colframe=bg,
  arc=0pt,
  shadow=false,
  new/use counter=equation,
  boxsep=1ex, top=0pt, left=0pt, right=0pt, bottom=0pt,
  comment={\hfill(\arabic{chapter}.\arabic{equation})},
  listing outside comment,
  righthand width=3em,
  sidebyside gap=0pt,
  minted language=#1,
  %before skip =-0.5\baselinestretch,
  %after skip=2\baselinestretch,
}

\BeforeBeginEnvironment{codefragment}{\begin{singlespace}\stepcounter{equation}}
\AfterEndEnvironment{codefragment}{\end{singlespace}}

\newmintinline[bash]{bash}{bgcolor=bg}
\newmintinline[python]{python}{bgcolor=bg}

\newcommand{\includepython}[1]{\inputminted[bgcolor=bg]{python}{#1}}
\newcommand{\includebash}[1]{\inputminted[bgcolor=bg]{bash}{#1}}
