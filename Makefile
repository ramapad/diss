## this makefile uses GNU-make-isms.  it's easier that way, 
# but means you will need to use "gmake" on BSD or Solaris 
# style systems.

# the name of the resulting file defaults to be basename of
# the current directory, I organize stuff in
# ~/mypapers/<papername>, then generate <papername>.{ps,pdf}
# if this subdirectory is "dissertation" or "thesis", that 
# will be the name of the output file.
FINALFILENAME=$(shell basename `pwd`)

# any rules with "shell" and the like will be := style
# variables: these are evaluated when the Makefile is
# loaded, not at every time when expanded.  this is to
# reduce the number of times grep gets called over all the
# .tex files.

## programs.  
PDFINFO:= $(shell which pdfinfo)
FIG2DEV=fig2dev
JGRAPH=jgraph
STYLECHECK=~/spring/style-check/style-check.rb
LACHECK=lacheck
# old versions of latex don't support -file-line-error-style; I 
# find it indispsensable.
LATEX=latex -file-line-error-style
DVIPS=dvips -t letter 
# a dependency for the spellchecker.
## perhaps someone can tell me how to use aspell with a personal dictionary
## that I can store in CVS.
## PERSONAL_DICTIONARY=./dictionary.aspell
## SPELLCHECKER=aspell --extra-dicts=$(PERSONAL_DICTIONARY) -c
SPELLCHECKER=ispell -x -t -p ./dictionary
# you may want your second run of latex to have a different style than the first.
# I prefer to let emacs ignore errors from the second run. (if they were 
# really errors, the second run shouldn't happen.
# SECONDLATEX=$(LATEX)
SECONDLATEX=latex 
PDFLATEX=pdflatex -file-line-error-style
#PDFLATEX=latex -file-line-error-style
# min-crossrefs makes it possible to use crossref in the .bib file without
# creating separate cite entries for the conference.
BIBTEX=bibtex -min-crossrefs=100

# where should "make public" send the files to, $(WEBDIR)/$(DEST)
WEBDIR=junkfood.cs.umd.edu:public_html
# I switch this from private to papers when I finish with it.
DEST=private
# DEST=papers

# what is the root .tex file.  I always use master.tex; you might
# use "main.tex" or "conferencename.tex".
MASTER=main

# the next three variables gain their values by parsing the
# tex files.  Only those within two \input (or \ninput) of
# the master tex file are considered, so if you have an
# arbitrarily multi- level hierarchy, you'll have to
# implement the recursive search.  Also, if you've indented
# your \input command, it will not be used.  This is handy
# if you want to segregate code or similar not-spell-check-worthy
# text into a different file that will not be passed to ispell:
# you may
# \begin{figure}
#   \begin{center}
#     \input{Program-output}
#   \end{center}
# \end{figure}
# That is, because I like indenting the stuff that goes inside 
# blocks, and I don't want to check the spelling of these things,
# ignoring indented inputs works.

# which files should be spellchecked by the spellcheck rule.
SPELLTEX_ZERO:=$(shell egrep '^\\\n?input' $(MASTER).tex | sed 's/^.*input[^{]*{//' | grep -v "\#1" | sed 's/}.*$$/.tex/')
SPELLTEX:=$(MASTER).tex $(SPELLTEX_ZERO) $(shell test -z "$(SPELLTEX_ZERO)" || egrep '^\\\n?input' $(SPELLTEX_ZERO) | sed 's/^.*input[^{]*{//' | grep -v "\#1" | sed 's/}.*$$/.tex/')

## the next couple rules will build graphics iff you use
## includegraphics (in the graphicx package), and specify
## the graphic filename *with no extension*.  includegraphics
## is smart enough to find the right file; this makefile
## will construct the right file from xfig or jgraph when
## needed.  you may add rules that generate .eps or .pdf
## from other file types.
# which files should be generated if not present.
#NEEDED_EPS:=$(shell grep \\includegraphics $(SPELLTEX) | grep -v "%.*includegraphics" | sed 's/^.*includegraphics[^{]*{//' | sed 's/}.*$$/.eps/' | grep -v '\#1.eps' )
# pdflatex can includegraphics .jpg files, so no need to convert.
NEEDED_PDF:=$(shell for i in `grep \\includegraphics *.tex */*.tex | grep -v "%.*includegraphics" | sed 's/^.*includegraphics[^{]*{//' | sed 's/}.*$$//' | grep -v '\#1'`; do test -e `echo $$i | sed 's/$$/.jpg/'` || (echo $$i | sed 's/$$/.pdf/'); done | grep -v $(FINALFILENAME).pdf )

# EPS files that can be removed are those that are backed by
# .jpg, .fig, .jgr files.  If you added another conversion to
# .eps, another || clause should be added.
CLEANABLE_EPS:=$(shell for i in $(NEEDED_EPS); do (test -e `echo $$i | sed 's/.eps/.jpg/'` || test -e `echo $$i | sed 's/.eps/.fig/'` || test -e `echo $$i | sed 's/.eps/.jgr/'`) && (echo $$i); done)
CLEANABLE_PDF:=$(shell for i in $(NEEDED_PDF); do (test -e `echo $$i | sed 's/.pdf/.fig/'` || test -e `echo $$i | sed 's/.pdf/.jgr/'`) && (echo $$i); done)

## the main rule: build postscript, pdf, dvi for fun
## (usually implied), and run the censor rule.
all: $(FINALFILENAME).pdf todo 

# @grep proposalend master.aux | grep -q 15 || (echo "ERROR: but it doesn't end on page 15."; exit 1)

extras: sb.pdf nspringcv.pdf summary.pdf bibliography.pdf fifteen.pdf

debug:
	echo NEEDED_EPS: $(NEEDED_EPS)

## a set of rules to build a pocket thesis 
papersave.tex: $(MASTER).tex  papersave.cls Makefile
	ruby -pe '$$_.gsub!(/\{uwthesis\}/,"\{papersave\}"); $$_.gsub!(/^\\(signaturepage|doctoralquoteslip)/,"")' < $(MASTER).tex > $@
papersave.pdf: papersave.tex $(wildcard */*.tex) $(wildcard *.tex)  $(NEEDED_PDF) 
	rm -f papersave.aux 
	$(PDFLATEX) papersave.tex </dev/null
	$(PDFLATEX) papersave.tex </dev/null
papersave.ps: papersave.dvi
	$(DVIPS) $< -o - | psbook | psnup -2 | psset -t -o - | sed 's//co/g' > $@
	@echo "now use lpr -Zsduplex papersave.ps"

unofficial.cls: uwthesis.cls Makefile unofficial.patch
	cp uwthesis.cls unofficial.cls && patch < unofficial.patch

unofficial.tex: $(MASTER).tex  unofficial.cls Makefile
	ruby -pe '$$_.gsub!(/\{uwthesis\}/,"\{unofficial\}"); $$_.gsub!(/^\\(signaturepage|doctoralquoteslip)/,"")' < $(MASTER).tex > $@
unofficial.pdf: unofficial.tex $(wildcard */*.tex) $(wildcard *.tex) $(NEEDED_PDF) 
	rm -f papersave.aux 
	$(PDFLATEX) unofficial.tex </dev/null
	@if grep -s citation $(MASTER).aux; then \
		if $(BIBTEX) unofficial | tee /dev/stderr | grep Warning | grep -v "Warning--I didn't find a database entry for" ; then \
			echo "no warnings allowed: remove $(MASTER).bbl and $(MASTER).aux"; \
		 	exit 1; \
		fi; \
	fi
	$(PDFLATEX) unofficial.tex </dev/null
	$(PDFLATEX) unofficial.tex </dev/null

## my favorite rule; like a lint for style.  requires my
## style checker (but should fail nicely if the style checker
## is not present).
censor: censor-dict 
	@if test -s Abstract.tex; then \
		echo "testing length of abstract < 350"; \
		ruby -e "exit(if (( v = IO.popen('grep -v ^% Abstract.tex | wc -w','r').readlines.first.split[0].to_i) < 350) then 0; else puts v.to_s + ' is too long'; 1; end)"; \
	fi
	@if test -s Abstract.tex; then \
		echo "testing length of abstract > 250"; \
		ruby -e "exit(IO.popen('wc -w Abstract.tex').readlines.first.split[0].to_i > 250 ? 0 : 1)" || echo "Abstract.tex:1 TODO: add information to the abstract."; \
	fi
	@if test -x /usr/bin/ruby && test -x $(STYLECHECK); then \
		$(STYLECHECK) -v $(SPELLTEX); \
	fi

diction: 
	diction -nf diction-file $(SPELLTEX)

showtodo: censor
	cat todo.lst

check:
	@if which $(LACHECK); then \
		for t in $(SPELLTEX); do \
			$(LACHECK) $$t; \
		done \
	fi

#	@if test -x /usr/bin/chktex; then \
#		chktex -n 8 -n 1 -n 26 -n 18 $(SPELLTEX); \
#	fi

todo:
	@if test -e todo.lst; then \
		cat todo.lst; \
	fi

## I also have a rule for censoring a file at a time.
%.censor: %.tex
	if test -x /usr/bin/ruby && test -x $(STYLECHECK); then \
		$(STYLECHECK) -v $<; \
	fi

## upload the output file to a webserver.
public: $(FINALFILENAME).ps $(FINALFILENAME).pdf censor todo
	scp $(FINALFILENAME).ps $(FINALFILENAME).pdf $(WEBDIR)/$(DEST)

## kind of overdone, just to make sure that a small problem,
## such as a broken aux file, doesn't break the build.
$(FINALFILENAME).pdf: $(wildcard */*.tex) $(wildcard *.tex) $(NEEDED_PDF) $(wildcard *.bib) $(wildcard *.cls) $(wildcard *.sty) $(wildcard *.bst) 
	rm -f $(MASTER).aux $(MASTER).lo[ft]
	$(PDFLATEX) $(MASTER).tex </dev/null
	@if grep -s citation $(MASTER).aux; then \
		if $(BIBTEX) $(MASTER) | tee /dev/stderr | grep Warning | grep -v "Warning--I didn't find a database entry for" ; then \
			echo "no warnings allowed: remove $(MASTER).bbl and $(MASTER).aux"; \
			exit 1; \
		fi; \
	fi
	$(PDFLATEX) $(MASTER).tex </dev/null
	$(PDFLATEX) $(MASTER).tex </dev/null
	# take care of annoying font embedding
	mv $(MASTER).pdf $@
	\cp $@ /tmp/$@

$(FINALFILENAME).ps2.pdf: $(FINALFILENAME).ps
	gs -q -dSAFER -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=$@ -dCompatibilityLevel=1.5 -dPDFSETTINGS=/prepress -c .setpdfwrite -f $<
 
$(FINALFILENAME).ps: $(wildcard */*.tex) $(wildcard *.tex) $(NEEDED_EPS) $(wildcard *.bib) $(wildcard *.cls) $(wildcard *.sty) $(wildcard *.bst) 
	rm -f $(MASTER).aux $(MASTER).lo[ft]
	$(LATEX) $(MASTER).tex </dev/null
	@if grep -s citation $(MASTER).aux; then \
		if $(BIBTEX) $(MASTER) | tee /dev/stderr | grep Warning | grep -v "Warning--I didn't find a database entry for" ; then \
			echo "no warnings allowed: remove $(MASTER).bbl and $(MASTER).aux"; \
			exit 1; \
		fi; \
	fi
	$(LATEX) $(MASTER).tex </dev/null
	$(LATEX) $(MASTER).tex </dev/null
	$(DVIPS) $(MASTER).dvi
	mv $(MASTER).ps $@
	\cp $@ /tmp/$@

show: $(FINALFILENAME).pdf
	echo $<
	#open $<

## ick.  I dislike latex2html...
$(FINALFILENAME)/$(MASTER).html: Makefile $(wildcard */*.tex) $(wildcard *.tex) /etc/latex2html.conf
	rm -rf $(FINALFILENAME)/
	mkdir -p $(FINALFILENAME)
	perl -MCarp=verbose /usr/bin/latex2html $(MASTER).tex -split 0 -dir $(FINALFILENAME) -white -no_navigation -info 0 -show_section_numbers

# would use $(MASTER).bbl, but it has to be possible to have 
# no bib at all.
$(MASTER).dvi: $(wildcard */*.tex) $(wildcard *.tex) $(wildcard *.bib) $(NEEDED_EPS) $(wildcard *.sty) $(wildcard *.bbl) $(MASTER).bbl

## how to build eps files from jgraph source.  I have two
## versions of a program that compresses the output of
## jgraph. (jgraph uses full postscript commands like
## "lineto" which are commonly redefined by most things that
## output postscript to one-character names like "l";
## compresseps adds such a dictionary and applies the new
## command names to the rest of the eps file.  It also
## eliminates useless precision: 0.00000000 can be replaced
## with 0.
%.eps: %.jgr ~/bin/compresseps
	JGRAPH_BORDER=5 $(JGRAPH) $< | ~/bin/compresseps > $@ || (rm $@; exit 1)
%.eps: %.jgr ./compresseps.pl
	JGRAPH_BORDER=5 $(JGRAPH) $< | ./compresseps.pl > $@ || (rm $@; exit 1)

# generate eps for graphics from xfig
# pstex does generate a showpage, apparently, so I forget why 
# I use this and not -Leps.
%.eps: %.fig 
	$(FIG2DEV) -Lpstex $< $@
## the -p x parameter gets proper portrait orientation when
## building pdf.
%.pdf: %.fig
	$(FIG2DEV) -Lpdf -p x $< $@

## a helper rule for previewing a jgr file.
%.ps: %.jgr
	JGRAPH_BORDER=5 $(JGRAPH) -P $< > $@ || rm $@


%.dvi: %.tex $(wildcard */*.tex) $(wildcard *.tex) $(NEEDED_EPS) $(wildcard *.bbl) 
	$(LATEX) $< </dev/null
	test -e $(MASTER).aux || (echo "failed to build an aux file for bibtex to chew on."; exit 1)
	@if grep -s citation $(MASTER).aux; then \
		if $(BIBTEX) $(MASTER) | tee /dev/stderr | grep Warning | grep -v "Warning--I didn't find a database entry for" ; then \
			echo "no warnings allowed: remove $(MASTER).bbl and $(MASTER).aux"; \
			exit 1; \
		fi; \
	fi
	mv $*.dvi $*-1.dvi
	$(SECONDLATEX) $< </dev/null
	diff -q $*.dvi $*-1.dvi > /dev/null || ($(LATEX) $<; echo "had to run thrice")
	rm $*-1.dvi

%.ps: %.dvi
	$(DVIPS) -o $@ $<

%.eps: %.bad-eps
	eps2eps $< $@

## build pdf from eps, unless there's a .fig file to start from instead.
%.pdf: %.eps
	@gs --version | egrep ^7 && (echo "WARNING: I don't trust gs version 7.x to render pdf" ; exit 1) || true
	(test -e $*.fig && $(FIG2DEV) -Lpdf -p x $*.fig $@) || (GS_OPTIONS=-dAutoRotatePages=/None epstopdf $< --outfile=$*.epdf && mv $*.epdf $@)

#%.bbl: %.aux net.bib
$(MASTER).bbl: $(wildcard *.bib) $(MASTER).aux
	test -e $(MASTER).aux || $(LATEX) $(MASTER).tex < /dev/null
	@if $(BIBTEX) $(MASTER) | tee /dev/stderr | grep Warning | grep -v "Warning--I didn't find a database entry for" ; then \
		echo "no warnings allowed: remove $(MASTER).bbl and $(MASTER).aux"; \
		exit 1; \
	fi

$(MASTER).aux: $(MASTER).tex
	$(LATEX) $< < /dev/null

## removes everything we think we built.
clean:
	rm -f $(MASTER).{aux,dvi,log,blg,bbl,lof,lot,out,toc} comment.cut comment.cut
	rm -f *~ core
	rm -f $(CLEANABLE_EPS) $(CLEANABLE_PDF)

## spellchecking rules for all the .tex files referenced by
## master.tex, or for a particular file at a time.
spellcheck: $(PERSONAL_DICTIONARY)
	$(SPELLCHECKER) summary.tex $(SPELLTEX) 
%.spell: %.tex
	$(SPELLCHECKER) $<

## build eps from dot.
%.eps: %.dot
	dot -Tps $< > $@ || rm $@
dots/fret.dot: dots/x.dot dots/reformatdot.rb
	dots/reformatdot.rb dots/x.dot > dots/fret.dot

## build eps from jpeg
%.eps: %.jpg 
	jpeg2ps $< > $@ || rm $@

## build eps from tiff 
%.eps: %.tiff
	tiff2ps $< > $@ || rm $@

## 
neededeps: $(NEEDED_EPS)

# %.pdf: %.ps
# 	ps2pdf $< $@

# %.pdf: %.obj
#	tgif -print -pdf $< > /dev/null
%.eps: %.obj
	tgif -print -eps -color $< > /dev/null
%.eps: %.dia
	dia -e $@ $<

%.pdf: %.gnuplot
	cd figs && gnuplot $(notdir $<) && epstopdf $(notdir $*).eps

figs/%.eps: figs/%.gnuplot
	cd figs && gnuplot $(notdir $<) || rm $@

publish: $(FINALFILENAME).pdf
	scp $(FINALFILENAME).pdf bluepill.cs.umd.edu:~/public_html/
	ssh bluepill.cs.umd.edu 'chmod a+r ~/public_html/$(FINALFILENAME).pdf'

#$(FINALFILENAME).tex:
#	grep -v -h "^%" *.tex | grep -v "todo" > $@ 
#	cat master.bbl >> $@ 

# figs/20150206_high_1pctile_gt_300ms_one_vs_99_scatter-nosat.eps: figs/20150206_high_1pctile_gt_300ms_one_vs_99_scatter-nosat.xcdf.jgr
# figs/20150206_high_1pctile_gt_300ms_one_vs_99_scatter-sat.eps: figs/20150206_high_1pctile_gt_300ms_one_vs_99_scatter-sat.xcdf.jgr

# figs/20150206_high_1pctile_gt_300ms_one_vs_99_scatter-nosat.xcdf.jgr: figs/cdfize-scatter.rb figs/20150206_high_1pctile_gt_300ms_one_vs_99_scatter-nosat.jgr
# 	cd figs && ruby cdfize-scatter.rb

# figs/20150206_high_1pctile_gt_300ms_one_vs_99_scatter-sat.xcdf.jgr: figs/cdfize-scatter.rb figs/20150206_high_1pctile_gt_300ms_one_vs_99_scatter-sat.jgr
# 	cd figs && ruby cdfize-scatter.rb

# figs/20150206_high_1pctile_gt_300ms_one_vs_99_scatter-nosat-decimated.jgr: figs/20150206_high_1pctile_gt_300ms_one_vs_99_scatter-nosat.jgr figs/decimate-jgr.rb
# 	cd figs && ruby decimate-jgr.rb
