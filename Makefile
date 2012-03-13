LATEX=xelatex

.PHONY: default pdf distclean clean

default: pdf

pdf: stadgar.pdf reglemente.pdf

stadgar.pdf: stadgar.tex
	$(LATEX) stadgar
	$(LATEX) stadgar

reglemente.pdf: reglemente.tex
	$(LATEX) reglemente
	$(LATEX) reglemente

distclean: clean
	rm -f stadgar.pdf reglemente.pdf

clean:
	rm -f *.aux *.log *.out
