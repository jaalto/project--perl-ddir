#!/usr/bin/make -f
#
#   Copyright information
#
#	Copyright (C) 2002-2025 Jari Aalto
#
#   License
#
#	This program is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; either version 2 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program. If not, see <http://www.gnu.org/licenses/>.

ifneq (,)
This makefile requires GNU Make.
endif

PACKAGE		= ddir
DESTDIR		=
prefix		= /usr
exec_prefix	= $(prefix)
man_prefix	= $(prefix)/share
mandir		= $(man_prefix)/man
bindir		= $(exec_prefix)/bin
sharedir	= $(prefix)/share

BINDIR		= $(DESTDIR)$(bindir)
DOCDIR		= $(DESTDIR)$(sharedir)/doc/$(PACKAGE)
LOCALEDIR	= $(DESTDIR)$(sharedir)/locale
SHAREDIR	= $(DESTDIR)$(sharedir)/$(PACKAGE)
LIBDIR		= $(DESTDIR)$(prefix)/lib/$(PACKAGE)
SBINDIR		= $(DESTDIR)$(exec_prefix)/sbin
ETCDIR		= $(DESTDIR)/etc/$(PACKAGE)

# 1 = regular, 5 = conf, 6 = games, 8 = daemons
MANDIR		= $(DESTDIR)$(mandir)
MANDIR1		= $(MANDIR)/man1
MANDIR5		= $(MANDIR)/man5
MANDIR6		= $(MANDIR)/man6
MANDIR8		= $(MANDIR)/man8

TAR		= tar
TAR_OPT_NO	= --exclude='.build'	 \
		  --exclude='.sinst'	 \
		  --exclude='.inst'	 \
		  --exclude='tmp'	 \
		  --exclude='*.bak'	 \
		  --exclude='*[~\#]'	 \
		  --exclude='.\#*'	 \
		  --exclude='CVS'	 \
		  --exclude='.svn'	 \
		  --exclude='.git'	 \
		  --exclude='.bzr'	 \
		  --exclude='*.tar*'	 \
		  --exclude='*.tgz'

INSTALL		= /usr/bin/install
INSTALL_BIN	= $(INSTALL) -m 755
INSTALL_DATA	= $(INSTALL) -m 644
INSTALL_SUID	= $(INSTALL) -m 4755
INSTALL_DIR	= $(INSTALL) -m 755 -d

DIST_DIR	= ../build-area
DATE		= $(shell date +"%Y.%m%d")
VERSION		= $(DATE)
RELEASE		= $(PACKAGE)-$(VERSION)

BIN		= $(PACKAGE)
PL_SCRIPT	= bin/$(BIN).pl

INSTALL_OBJS_BIN   = $(PL_SCRIPT)
INSTALL_OBJS_DOC   = README COPYING
INSTALL_OBJS_MAN   = bin/*.1

XARGS		= xargs xargs --no-run-if-empty
PERL		= perl

# Do not chnage this. This is the location of "local" auto generated
# files. Fromt here the fle are installed to $(DOCDIR)

docdir = doc/manual
manpage = bin/$(PACKAGE).1

.PHONY: all
all: doc
	# target: all
	@echo "For more information, see 'make help'"

# Rule: help - Display Makefile rules
.PHONY: help
help:
	grep "^[[:space:]]*# Rule:" Makefile | sed 's/^[[:space:]]*//' | sort

# Rule: clean - remove temporary files
.PHONY: clean
clean:
	# target: clean
	find .	-name "*[#~]" \
		-o -name "*.\#*" \
		-o -name "*.x~~" \
		-o -name "pod*.tmp" | \
	$(XARGS) rm -f

	rm -rf tmp

.PHONY: distclean
distclean: clean
	# Rule: distclean - remove everything that can be generated
	rm -f $(manpage)
	rm -rf $(docdir)

.PHONY: realclean
realclean: clean

.PHONY: dist-git
dist-git: test doc
	rm -f $(DIST_DIR)/$(RELEASE)*

	git archive --format=tar --prefix=$(RELEASE)/ master | \
	gzip --best > $(DIST_DIR)/$(RELEASE).tar.gz

	chmod 644 $(DIST_DIR)/$(RELEASE).tar.gz

	tar -tvf $(DIST_DIR)/$(RELEASE).tar.gz | sort -k 5
	ls -la $(DIST_DIR)/$(RELEASE).tar.gz

# The "gt" is maintainer's program frontend to Git
# Rule: dist-snap - [maintainer] release snapshot from Git repository
.PHONY: dist-snap
dist-snap: test doc
	@echo gt tar -q -z -p $(PACKAGE) -c -D master

# Rule: dist-git - [maintainer] make release archive
.PHONY: dist
dist: dist-git

.PHONY: dist-ls
dist-ls:
	@ls -1tr $(DIST_DIR)/$(PACKAGE)*

# Rule: dist - [maintainer] list of release files
.PHONY: ls
ls: dist-ls

.PHONY: docdir
docdir:
	# target: docdir - create documentation output directory
	$(INSTALL_DIR) $(docdir)

$(manpage): $(PL_SCRIPT)
	# target: bin/$(PACKAGE).1
	$(PERL) $< --help-man > $@
	@-rm -f *.x~~ pod*.tmp

doc/manual/$(PACKAGE).html: $(PL_SCRIPT)
	# target: doc/manual/$(PACKAGE).html
	$(PERL) $< --help-html > $@
	@-rm -f *.x~~ pod*.tmp

doc/manual/$(PACKAGE).txt: $(PL_SCRIPT)
	# target: doc/manual/$(PACKAGE).txt
	$(PERL) $< --help > $@
	@-rm -f *.x~~ pod*.tmp

doc/conversion/index.html: doc/conversion/index.txt
	perl -S t2html.pl --Auto-detect --Out --print-url $<

# Rule: man - Generate or update manual page
.PHONY: man
man: docdir $(manpage)

# Rule: html - Generate HTML pages
.PHONY: html
html: docdir test-pod doc/manual/$(PACKAGE).html

# Rule: txt - Generate TXT pages
.PHONY: txt
txt: docdir test-pod doc/manual/$(PACKAGE).txt

# Rule: doc - Generate or update all documentation
.PHONY: doc
doc: man html txt

.PHONY: test-pod
test-pod:
	# Rule: pod-test - Check POD syntax
	podchecker $(PL_SCRIPT)

.PHONY: test-perl
test-perl:
	# Rule: perl-test - Check program syntax
	perl -cw $(PL_SCRIPT)

# Rule: test - Run all tests
.PHONY: test
test: test-perl test-pod

# Rule: install-doc - Install documentation
.PHONY: install-doc
install-doc:
	$(INSTALL_BIN) -d $(DOCDIR)

	[ ! "$(INSTALL_OBJS_DOC)" ] || \
		$(INSTALL_DATA) $(INSTALL_OBJS_DOC) $(DOCDIR)

	$(TAR) -C doc $(TAR_OPT_NO) --create --file=- . | \
	$(TAR) -C $(DOCDIR) --extract --file=-

.PHONY: install-man
install-man: man
	# Rule: install-man - Install manual pages
	$(INSTALL_BIN) -d $(MANDIR1)
	$(INSTALL_DATA) $(INSTALL_OBJS_MAN) $(MANDIR1)

install-bin:
	# Rule: install-bin - Install programs
	$(INSTALL_BIN) -d $(BINDIR)
	for f in $(INSTALL_OBJS_BIN); \
	do \
		dest=$$(basename $$f | sed -e 's/\.pl$$//' -e 's/\.py$$//' ); \
		$(INSTALL_BIN) $$f $(BINDIR)/$$dest; \
	done

# Rule: install - Standard install. Use variables like: DESTDIR= prefix=/usr/local
.PHONY: install
install: install-bin install-man install-doc

# Rule: install-test - [maintainer] Dry-run install to tmp/ directory
.PHONY: install-test
install-test:
	rm -rf tmp
	make DESTDIR=$(shell pwd)/tmp prefix=/usr install
	find tmp | sort

# End of file
