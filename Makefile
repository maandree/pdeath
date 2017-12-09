.POSIX:

CONFIGFILE = config.mk
include $(CONFIGFILE)

all: pdeath tinysleep test

pdeath: pdeath.o
	$(CC) -o $@ pdeath.o $(LDFLAGS)

tinysleep: tinysleep.o
	$(CC) -o $@ tinysleep.o $(LDFLAGS)

test: test.o
	$(CC) -o $@ test.o $(LDFLAGS)

.c.o:
	$(CC) -c -o $@ $< $(CPPFLAGS) $(CFLAGS)

check: pdeath tinysleep test
	./pdeath -L >/dev/null
	./pdeath -L | grep ABRT >/dev/null
	./pdeath -L | grep FPE >/dev/null
	./pdeath -L | grep ILL >/dev/null
	./pdeath -L | grep INT >/dev/null
	./pdeath -L | grep SEGV >/dev/null
	./pdeath -L | grep TERM >/dev/null
	! ./pdeath 2>/dev/null
	! ./pdeath KILL 2>/dev/null
	./pdeath KILL true
	! ./pdeath KILL false
	./pdeath 1 true
	./pdeath 1+1 true
	./pdeath 2-1 true
	! ./pdeath - true 2>/dev/null
	! ./test
	./pdeath KILL ./test
	mkdir -p .testdir
	sleep 1 & printf '%i\n' $$! > .testdir/pid; ./tinysleep
	kill -0 $$(cat .testdir/pid)
	./pdeath KILL sleep 1 & printf '%i\n' $$! > .testdir/pid; ./tinysleep
	! kill -0 $$(cat .testdir/pid) 2>/dev/null
	rm -r .testdir

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
	-rm -rf -- *.o pdeath tinysleep test .testdir

SUFFIXES:
SUFFIXES: .o .c

.PHONY: all check install uninstall clean
