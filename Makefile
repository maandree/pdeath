PREFIX = /usr
BINDIR = $(PREFIX)/bin
DATADIR = $(PREFIX)/share
LICENSEDIR = $(DATADIR)/licences

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

uninstall:
	-rm -- "$(DESTDIR)$(BINDIR)/$(COMMAND)"

clean:
	-rm -rf bin
