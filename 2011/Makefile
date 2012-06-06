LATEX=xelatex
RUBY=ruby

LATEX_OPTS=-output-directory 2011

.PHONY: default pdf distclean clean

default: pdf

pdf: verksamhetsplan.pdf

verksamhetsplan.pdf: verksamhetsplan.tex
	(cd .. && $(LATEX) $(LATEX_OPTS) 2011/verksamhetsplan)
	(cd .. && $(LATEX) $(LATEX_OPTS) 2011/verksamhetsplan)

textile: verksamhetsplan.textile

verksamhetsplan.textile:
	$(RUBY) ../textilize.rb verksamhetsplan.tex

toc: verksamhetsplan.toc.textile

verksamhetsplan.toc.textile: verksamhetsplan.textile
	$(RUBY) ../toc_gen.rb verksamhetsplan.textile

distclean: clean
	rm -f verksamhetsplan.pdf

clean:
	rm -f *.aux *.log *.out *.textile
