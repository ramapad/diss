\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ns-article}[2003/06/21 Neil Spring, UW CSE]
%\LoadClass[twocolumn,10pt]{report} 
\LoadClass[onecolumn,12pt]{report} 
\renewcommand\LARGE{\@setfontsize\LARGE\@xivpt{14\p@}}
%\newcommand\bibfontsize{\@setfontsize\bibfontsize\@viiipt{8\p@}}
\newcommand\bibfontsize{\@setfontsize\bibfontsize\@xiipt{12\p@}}
%\newcommand\scriptsize{\@setfontsize\scriptsize\@viipt{8\p@}}

\def\abstract{\begin{center}%
{\large\bf \abstractname\vspace{-.5em}\vspace{\z@}}%
\end{center}}
\def\endabstract{}


\newif\ifdraft
\DeclareOption{draft}{\drafttrue}

\newif\ifsingle
\DeclareOption{single}{\singletrue}

\newif\iftodo
\DeclareOption{todo}{\todotrue}
\ProcessOptions

\RequirePackage{geometry}
\ifsingle
	\geometry{letterpaper, textheight=9in, textwidth=6.5in, columnsep=0.25in}
\else
	\geometry{letterpaper, textheight=9in, textwidth=5.9in, columnsep=0.25in}
\fi

\RequirePackage{times} % like times, only better for courier.

\RequirePackage{url}
\RequirePackage{comment}
\RequirePackage{color}
\RequirePackage{pifont}
\RequirePackage{amsmath}
\RequirePackage{multirow}
\RequirePackage{latexsym}
\RequirePackage{ifpdf}

\ifpdf
  \usepackage[pdftex]{graphicx}
\else
  \usepackage{graphicx}
\fi

% DML - for html
% \DeclareSymbolHtml{\checkmark}{X2713}

\hyphenation{Pla-net-Lab}
\hyphenation{every-where}
\hyphenation{time-stamps}

\widowpenalty=4000
\clubpenalty=4000

\urlstyle{rm}

\newcommand{\ninput}[1]{\renewcommand{\thisfile}{#1.tex}\input{#1}}
% from the latex faq
\def\ThisFile{\jobname}
\newcounter{FileStack}
\let\OrigInput\input
\renewcommand{\ninput}[1]{%
  \stepcounter{FileStack}
  \expandafter\let
  \csname NameStack\theFileStack\endcsname
  \ThisFile
  \def\ThisFile{#1}%
  \OrigInput{#1}%
  \expandafter\let\expandafter
  \ThisFile
  \csname NameStack\theFileStack\endcsname
  \addtocounter{FileStack}{-1}%
}

\definecolor{todocolor}{rgb}{0.8,0.2,0.2}
% what I do with stuff in the faq.
\newcommand{\todo}[1]{\textsf{\color{todocolor} #1}\typeout{\ThisFile.tex:\the\inputlineno: TODO: #1}} %\GenericWarning{#1}}
\newcommand{\wontfix}[1]{}
\newcommand{\done}[1]{}

\newwrite\todoout
\immediate\openout\todoout=todo.lst
\iftodo
\renewcommand{\todo}[1]{\immediate\write\todoout{\ThisFile.tex:\the\inputlineno: TODO: #1}\textsf{\color{todocolor} TODO:~#1}} 
\else
\renewcommand{\todo}[1]{\immediate\write\todoout{\ThisFile.tex:\the\inputlineno: TODO: #1}} 
\fi

\newlength{\belowheadingdefault}
\setlength{\belowheadingdefault}{1.5ex \@plus .2ex}
\newlength{\aboveheadingdefault}
\setlength{\aboveheadingdefault}{-3.25ex\@plus -1ex \@minus -.2ex}

\renewcommand\section{\@startsection {section}{1}{\z@}%
                                   {0.30\aboveheadingdefault plus -0.5ex}% -0.3ex plus -0.1ex}%
                                   {0.20\belowheadingdefault plus 0.2ex}% -0.3ex plus -0.1ex}%
                                   {\normalfont\large\bfseries}}
                                   %{\normalfont\Large\bfseries}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                   {0.20\aboveheadingdefault plus -0.40ex}% -0.3ex plus -0.1ex}%
                                   {0.15\belowheadingdefault plus 0.1ex}% -0.3ex plus -0.1ex}%
                                     {\normalfont\large\bfseries}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
                                   {0.1\aboveheadingdefault}% -0.3ex plus -0.1ex}%
                                   {0.1\belowheadingdefault}% -0.3ex plus -0.1ex}%
                                     {\normalfont\normalsize\bfseries}}
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
                                    {0.4ex \@plus 0.1ex \@minus.2ex}%
                                    {-1em}%
                                    {\normalfont\normalsize\itshape}}                      

\renewenvironment{quote}{\begin{footnotesize}\list{}{\leftmargin 1em%
    \topsep 0em plus 0.05ex minus 0.05ex%
    \rightmargin 1em}%
  \item\relax}
  {\endlist\end{footnotesize}}

\setlength\abovecaptionskip{4pt plus 6pt}

% the following macro sequence doesn't seem to get topsep right.
%%%% debut macro %%%%
%% ----------------------------------------------------
%% Copyright (c) 1993 Hydro-Quebec [EMAIL PROTECTED]
%% ----------------------------------------------------

%% Bring items closer together in list environments 
% Prevent infinite loops
\let\orig@Itemize =\itemize         
\let\orig@Enumerate =\enumerate
\let\orig@Description =\description
% Zero the vertical spacing parameters
\def\Nospacing{\itemsep=0pt\topsep=0pt\partopsep=0pt%
\parskip=0pt\parsep=0pt}
% Redefinition de art12.sty pour commencer a la marge de gauche
%\leftmargini 1.2em      % 2.5em

\def\noitemsep{
% Redefine the environments in terms of the original values
\renewenvironment{itemize}{\orig@Itemize\Nospacing}{\endlist}
\renewenvironment{enumerate}{\orig@Enumerate\Nospacing}{\endlist}
\renewenvironment{description}{\orig@Description\Nospacing}%
{\endlist}
}

\def\doitemsep{
% Redefine the environments to the original values
\renewenvironment{itemize}{\orig@Itemize}{\endlist}
\renewenvironment{enumerate}{\orig@Enumerate}{\endlist}
\renewenvironment{description}{\orig@Description}{\endlist}
}
%%%% fin macro %%%%
\noitemsep



% \def\enumerate{%
%   \ifnum \@enumdepth >\thr@@\@toodeep\else
%     \advance\@enumdepth\@ne
%     \edef\@enumctr{enum\romannumeral\the\@enumdepth}%
%       \expandafter
%       \list
%         \csname label\@enumctr\endcsname
%         {\usecounter\@enumctr\def\makelabel##1{\hss\llap{##1}}}%
%   \fi}
% \let\endenumerate =\endlist

