LATEX=xelatex
RUBY=ruby

LATEX_OPTS=-output-directory 2013

default: pdf

pdf: verksamhetsplan.pdf

verksamhetsplan.pdf: verksamhetsplan.tex
	(cd .. && $(LATEX) $(LATEX_OPTS) 2013/verksamhetsplan)
	(cd .. && $(LATEX) $(LATEX_OPTS) 2013/verksamhetsplan)

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
