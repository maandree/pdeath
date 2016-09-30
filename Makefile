PREFIX = /usr
BINDIR = $(PREFIX)/bin
DATADIR = $(PREFIX)/share
LICENSEDIR = $(DATADIR)/licences
MANDIR = $(DATADIR)/man
MAN1DIR = $(MANDIR)/man1

PKGNAME = pdeath
COMMAND = pdeath

OPTIMISE = -O2
WARN = -Wall -Wextra -pedantic


all: cmd

cmd: bin/pdeath

bin/pdeath: src/pdeath.c
	@mkdir -p bin
	$(CC) -std=c99 $(OPTIMISE) $(WARN) -o $@ $^

install: bin/pdeath
	mkdir -p -- "$(DESTDIR)$(BINDIR)"
	cp -- bin/pdeath "$(DESTDIR)$(BINDIR)/$(COMMAND)"
	mkdir -p -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	cp -- LICENSE "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"
	mkdir -p -- "$(DESTDIR)$(MAN1DIR)"
	cp doc/pdeath.1 -- "$(DESTDIR)$(MAN1DIR)/$(COMMAND).1"

uninstall:
	-rm -- "$(DESTDIR)$(BINDIR)/$(COMMAND)"
	-rm -- "$(DESTDIR)$(MAN1DIR)/$(COMMAND).1"
	-rm -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"
	-rmdir -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"

clean:
	-rm -rf bin
