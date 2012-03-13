LATEX=xelatex

.PHONY: default pdf distclean clean

default: pdf

pdf: stadgar.pdf

stadgar.pdf: stadgar.tex
	$(LATEX) stadgar
	$(LATEX) stadgar

distclean: clean
	rm -f stadgar.pdf

clean:
	rm -f *.aux *.log *.out
