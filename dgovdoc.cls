%%
%% Stil för Konglig Datasektionens styrdokument
%%
%% Delvis baserad på filen kth-mag,
%% i övrigt mest copypasta.
%%
%% Andreas Tarandi, taran@kth.se
%% Victor Koronen, koronen@kth.se
%% Version 0.1, 2012-03-26
%%

\NeedsTeXFormat{LaTeX2e}[2001/01/01]
\ProvidesClass{dgovdoc}
              [2012/03/26 v0.1 Document Class for Konglig Datasektionen's governing documents]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ExecuteOptions{a4paper}
\ExecuteOptions{12pt}
\ProcessOptions\relax
\LoadClass[a4paper,12pt]{article}

\AtBeginDocument{\RequirePackage{graphicx}}

\def\logo#1{\gdef\@logo{#1}}
\def\organisation#1{\gdef\@organisation{#1}}
\def\@logo{dsekt.eps}
\def\@organisation{Konglig Datasektionen}
\renewcommand{\maketitle}{
	\hspace{-2.5cm}
	\begin{minipage}[b]{0.4\linewidth}
		\center
		\includegraphics[scale=0.25]{dsekt.eps}
	\end{minipage}
	\hspace{-1cm}
	\begin{minipage}[b]{0.85\linewidth}
		\huge \textbf{\@title}\\
		\LARGE \textsc{\@organisation}
		\vspace{0.5cm}
	\end{minipage}
}

\endinput
