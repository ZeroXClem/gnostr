CFLAGS                                  = -Wall -O2 -Ideps/secp256k1/include
CFLAGS                                 += -I/include
LDFLAGS                                 = -Wl -V
OBJS                                    = sha256.o gnostr.o       aes.o base64.o
GNOSTR_GIT_OBJS                         = sha256.o gnostr-git.o   aes.o base64.o
GNOSTR_RELAY_OBJS                       = sha256.o gnostr-relay.o aes.o base64.o
GNOSTR_XOR_OBJS                         = gnostr-xor.o
HEADER_INCLUDE                          = include
HEADERS                                 = $(HEADER_INCLUDE)/hex.h \
                                         $(HEADER_INCLUDE)/random.h \
                                         $(HEADER_INCLUDE)/config.h \
                                         $(HEADER_INCLUDE)/sha256.h \
                                         deps/secp256k1/include/secp256k1.h

ifneq ($(prefix),)
	PREFIX                             :=$(prefix)
else
	PREFIX                             :=/usr/local
endif
#export PREFIX

ARS                                     = libsecp256k1.a libgit.a libjq.a libtclstub.a

SUBMODULES                              = deps/secp256k1 deps/git deps/jq deps/nostcat deps/hyper-nostr deps/tcl deps/hyper-sdk

VERSION                                :=$(shell cat version)
export VERSION
GTAR                                   :=$(shell which gtar)
export GTAR
TAR                                    :=$(shell which tar)
export TAR

##all:
all: gnostr gnostr-git gnostr-relay gnostr-xor docs## 	make gnostr gnostr-git gnostr-relay gnostr-xor docs

##docs:
##	doc/gnostr.1 docker-start
docs: doc/gnostr.1 docker-start## 	docs: convert README to doc/gnostr.1
#@echo docs
	@bash -c 'if pgrep MacDown; then pkill MacDown; fi; 2>/dev/null'
	@bash -c 'cat $(PWD)/sources/HEADER.md                >  $(PWD)/README.md 2>/dev/null'
	@bash -c 'cat $(PWD)/sources/COMMANDS.md              >> $(PWD)/README.md 2>/dev/null'
	@bash -c 'cat $(PWD)/sources/FOOTER.md                >> $(PWD)/README.md 2>/dev/null'
	if hash pandoc 2>/dev/null; then \
		bash -c 'pandoc -s README.md -o index.html' 2>/dev/null; \
		fi || if hash docker 2>/dev/null; then \
		docker run --rm --volume "`pwd`:/data" --user `id -u`:`id -g` pandoc/latex:2.6 README.md; \
		fi
	@git add --ignore-errors sources/*.md 2>/dev/null
	@git add --ignore-errors *.md 2>/dev/null
#@git ls-files -co --exclude-standard | grep '\.md/$\' | xargs git

doc/gnostr.1: README## 	
	scdoc < $^ > $@

.PHONY: version
version: gnostr.c## 	print version
	@grep '^#define VERSION' $< | sed -En 's,.*"([^"]+)".*,\1,p' > $@
	@cat $@

dist: docs version## 	create tar distribution
	touch deps/tcl/unix/dltest/pkgπ.c
	touch deps/tcl/unix/dltest/pkg\317\200.c
	cp deps/tcl/unix/dltest/pkgπ.c deps/tcl/unix/dltest/pkg\317\200.c
	mkdir -p dist
	cat version > CHANGELOG && git add -f CHANGELOG && git commit -m "CHANGELOG: update" 2>/dev/null || echo
	git log $(shell git describe --tags --abbrev=0)..@^1 --oneline | sed '/Merge/d' >> CHANGELOG
	cp CHANGELOG dist/CHANGELOG.txt
	git ls-files --recurse-submodules | $(GTAR) --exclude='"deps/tcl/unix/dltest/*.c"' \
		--transform  's/^/gnostr-$(VERSION)\//' -T- -caf dist/gnostr-$(VERSION).tar.gz
	ls -dt dist/* | head -n1 | xargs echo "tgz "
	cd dist && \
		rm SHA256SUMS.txt || echo && \
		sha256sum *.tar.gz > SHA256SUMS.txt && \
		gpg -u 0xE616FA7221A1613E5B99206297966C06BB06757B \
		--sign --armor --detach-sig --output SHA256SUMS.txt.asc SHA256SUMS.txt
	##rsync -avzP dist/ charon:/www/cdn.jb55.com/tarballs/gnostr/

.PHONY:submodules
submodules:deps/secp256k1/.git deps/jq/.git deps/git/.git deps/nostcat/.git deps/tcl/.git deps/hyper-sdk/.git deps/hyper-nostr/.git## 	refresh-submodules
#	@git submodule update --init --recursive
	@git submodule foreach --recursive "git submodule update --init --recursive;"
	#@git submodule foreach --recursive "git fetch --all;"

#.PHONY:deps/secp256k1/config.log
.ONESHELL:
deps/secp256k1/.git:
deps/secp256k1/include/secp256k1.h: deps/secp256k1/.git
deps/secp256k1/configure: deps/secp256k1/include/secp256k1.h
	cd deps/secp256k1 && \
		./autogen.sh
deps/secp256k1/config.log: deps/secp256k1/configure
	cd deps/secp256k1 && \
		./configure --enable-module-ecdh --enable-module-schnorrsig --enable-module-extrakeys
deps/secp256k1/.libs/libsecp256k1.a:deps/secp256k1/config.log
	cd deps/secp256k1 && \
		make -j && make install #libsecp256k1.a
#.PHONY:libsecp256k1.a
libsecp256k1.a: deps/secp256k1/.libs/libsecp256k1.a## libsecp256k1.a
	cp $< $@
##libsecp256k1.a
##	deps/secp256k1/.git
##	deps/secp256k1/include/secp256k1.h
##	deps/secp256k1/./autogen.sh
##	deps/secp256k1/./configure


deps/jq/modules/oniguruma.git:
	@devtools/refresh-submodules.sh $(SUBMODULES)
	#cd deps/jq/modules/oniguruma && ./autogen.sh && ./configure && make && make install
deps/jq/.git:#deps/jq/modules/oniguruma.git
#.PHONY:deps/jq/.libs/libjq.a
deps/jq/.libs/libjq.a:deps/jq/.git
	cd deps/jq && \
		autoreconf -fi && ./configure --disable-maintainer-mode && make all install && cd ../..
##libjq.a
##	cp $< deps/jq/libjq.a .
libjq.a: deps/jq/.libs/libjq.a## 	libjq.a
	cp $< $@

deps/git/.git:
	@devtools/refresh-submodules.sh $(SUBMODULES)
deps/git/libgit.a:deps/git/.git
	cd deps/git && \
		make install
##libgit.a
##	deps/git/libgit.a deps/git/.git
##	cd deps/git; \
##	make install
libgit.a: deps/git/libgit.a## 	libgit.a
	cp $< $@

deps/tcl/.git:
	@devtools/refresh-submodules.sh $(SUBMODULES)
deps/tcl/unix/libtclstub.a:deps/tcl/.git
	cd deps/tcl/unix && \
		./autogen.sh configure && ./configure && make install
libtclstub.a:deps/tcl/unix/libtclstub.a## 	deps/tcl/unix/libtclstub.a
	cp $< $@
##tcl-unix
##	deps/tcl/unix/libtclstub.a deps/tcl/.git
##	cd deps/tcl/unix; \
##	./autogen.sh configure && ./configure && make install
tcl-unix:libtclstub.a## 	deps/tcl/unix/libtclstub.a

deps/nostcat/.git:
	@devtools/refresh-submodules.sh $(SUBMODULES)
#.PHONY:deps/nostcat
deps/nostcat:deps/nostcat/.git
deps/nostcat/target/release/nostcat:deps/nostcat
	cd deps/nostcat && \
		make cargo-install
#.PHONY:deps/nostcat
##nostcat
##deps/nostcat deps/nostcat/.git
##	cd deps/nostcat; \
##	make cargo-install
nostcat:deps/nostcat/target/release/nostcat## 	nostcat
	@cp $@ nostcat || echo "" 2>/dev/null

deps/hyper-sdk/.git:
	@devtools/refresh-submodules.sh $(SUBMODULES)
deps/hyper-nostr/.git:
	@devtools/refresh-submodules.sh $(SUBMODULES)

%.o: %.c $(HEADERS)
	@echo "cc $<"
	@$(CC) $(CFLAGS) -c $< -o $@

##initialize
##	git submodule update --init --recursive
initialize:## 	ensure submodules exist
	#git submodule update --init --recursive
gnostr:initialize $(HEADERS) $(OBJS) $(ARS)## 	make gnostr binary
##gnostr initialize
##	git submodule update --init --recursive
##	$(CC) $(CFLAGS) $(OBJS) $(ARS) -o $@
	git submodule update --init --recursive
	$(CC) $(CFLAGS) $(OBJS) $(ARS) -o $@

gnostr-git:initialize $(HEADERS) $(GNOSTR_GIT_OBJS) $(ARS)## 	make gnostr-git
##gnostr-git
	git submodule update --init --recursive
	$(CC) $(CFLAGS) $(GNOSTR_GIT_OBJS) $(ARS) -o $@

gnostr-relay:initialize $(HEADERS) $(GNOSTR_RELAY_OBJS) $(ARS)## 	make gnostr-relay
##gnostr-relay
	git submodule update --init --recursive
	$(CC) $(CFLAGS) $(GNOSTR_RELAY_OBJS) $(ARS) -o $@

#.PHONY:gnostr-xor
gnostr-xor: $(HEADERS) $(GNOSTR_XOR_OBJS) $(ARS)## 	make gnostr-xor
##gnostr-xor
	echo $@
	touch $@
	rm -f $@
	$(CC) $@.c -o $@

.ONESHELL:
##install all
##	install docs/gnostr.1 gnostr gnostr-query
install: all## 	install docs/gnostr.1 gnostr gnostr-query gnostr-relay gnostr-xor
	mkdir -p $(PREFIX)/bin
	mkdir -p $(PREFIX)/include
	install -m755 -vC include/*.*  ${PREFIX}/include/
	install -m644 -vC doc/gnostr.1 $(PREFIX)/share/man/man1/gnostr.1
	install -m755 -vC gnostr       $(PREFIX)/bin/gnostr
	install -m755 -vC gnostr-git   $(PREFIX)/bin/gnostr-git
	install -m755 -vC gnostr-relay $(PREFIX)/bin/gnostr-relay
	install -m755 -vC gnostr-xor   $(PREFIX)/bin/gnostr-xor

.PHONY:config.h
config.h: configurator
	./configurator > $@

.PHONY:configurator
##configurator
##	rm -f configurator
##	$(CC) $< -o $@
configurator: configurator.c
	rm -f configurator
	$(CC) $< -o $@

##clean
##	remove gnostr *.o *.a gnostr.1
clean:## 	remove gnostr *.o *.a gnostr.1
	rm -rf $(shell which gnostr)
	rm -rf /usr/local/share/man/man1/gnostr.1
	rm -f gnostr *.o *.a

##clean-hyper-nostr
##	remove deps/hyper-nostr
clean-hyper-nostr:## 	remove deps/hyper-nostr
	rm -rf deps/hyper-nostr

##clean-hyper-sdk
##	remove deps/hypersdk
clean-hyper-sdk:## 	remove deps/hyper-sdk
	rm -rf deps/hyper-sdk

##clean-secp
##	remove deps/secp256k1
clean-secp:## 	remove deps/secp256k1
	rm -rf deps/secp256k1

##clean-git
##	remove deps/git
clean-git:## 	remove deps/git
	rm -rf deps/git

##clean-tcl
##	remove deps/tcl
clean-tcl:## 	remove deps/tcl
	rm -rf deps/tcl
##clean-jq
##	remove deps/jq
clean-jq:## 	remove deps/jq
	rm -rf deps/jq
clean-all:clean clean-hyper-nostr clean-secp clean-git clean-tcl clean-jq## 	
##clean-all
##	clean clean-hyper-nostr clean-secp clean-git clean-tcl clean-jq

.PHONY: fake
