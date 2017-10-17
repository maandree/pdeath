.POSIX:

CONFIGFILE = config.mk
include $(CONFIGFILE)

all: pdeath

.o:
	$(CC) -o $@ $^ $(LDFLAGS)

.c.o:
	$(CC) -o $@ $< $(CPPFLAGS) $(CFLAGS)

install: pdeath
	mkdir -p -- "$(DESTDIR)$(PREFIX)/bin"
	mkdir -p -- "$(DESTDIR)$(PREFIX)/share/licenses/pdeath"
	mkdir -p -- "$(DESTDIR)$(MANPREFIX)/man1"
	cp -- pdeath "$(DESTDIR)$(PREFIX)/bin/"
	cp -- LICENSE "$(DESTDIR)$(PREFIX)/share/licenses/pdeath/"
	cp -- pdeath.1 "$(DESTDIR)$(MANPREFIX)/man1/"

uninstall:
	-rm -f -- "$(DESTDIR)$(PREFIX)/bin/pdeath"
	-rm -f -- "$(DESTDIR)$(MANPREFIX)/man1/pdeath.1"
	-rm -rf -- "$(DESTDIR)$(PREFIX)/share/licenses/pdeath"

clean:
	-rm -f -- *.o pdeath

SUFFIXES: .o .c.o

.PHONY: all check install uninstall clean
