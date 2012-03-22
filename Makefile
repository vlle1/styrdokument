LATEX=xelatex
RUBY=ruby

.PHONY: default pdf distclean clean

default: pdf

pdf: stadgar.pdf reglemente.pdf

stadgar.pdf: stadgar.tex
	$(LATEX) stadgar
	$(LATEX) stadgar

reglemente.pdf: reglemente.tex
	$(LATEX) reglemente
	$(LATEX) reglemente

textile: stadgar.textile reglemente.textile

stadgar.textile:
	$(RUBY) textilize.rb stadgar.tex

reglemente.textile:
	$(RUBY) textilize.rb reglemente.tex

toc: stadgar.toc.textile reglemente.toc.textile

stadgar.toc.textile: stadgar.textile
	$(RUBY) toc_gen.rb stadgar.textile

reglemente.toc.textile: reglemente.textile
	$(RUBY) toc_gen.rb reglemente.textile

distclean: clean
	rm -f stadgar.pdf reglemente.pdf

clean:
	rm -f *.aux *.log *.out *.textile
