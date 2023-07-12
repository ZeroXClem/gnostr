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
##	remove deps/secp256k1/.libs/libsecp256k1.*
clean-secp:## 	remove deps/secp256k1/.libs/libsecp256k1.* libsecp256k1.a
	rm -rf deps/secp256k1/.libs/libsecp256k1.*
	rm libsecp256k1.a

##clean-gnostr-git
##	remove deps/gnostr-git/gnostr-git
##	remove gnostr-git
clean-gnostr-git:## 	remove deps/gnostr-git gnostr-git
	#rm -rf deps/gnostr-git
	rm deps/gnostr-git/gnostr-git
	rm gnostr-git

##clean-gnostr-cat
##	remove deps/gnostr-cat
clean-gnostr-cat:## 	remove deps/gnostr-cat
	rm -rf deps/gnostr-cat

##clean-gnostr-relay
##	remove deps/gnostr-relay
clean-gnostr-relay:## 	remove deps/gnostr-relay
	rm -rf deps/gnostr-relay

##clean-tcl
##	remove deps/tcl
clean-tcl:## 	remove deps/tcl
	rm -rf deps/tcl

##clean-jq
##	remove deps/jq
clean-jq:## 	remove deps/jq
	rm -rf deps/jq
clean-all:clean clean-hyper-nostr clean-secp clean-gnostr-git clean-tcl clean-jq## 	clean clean-*
##clean-all
##	clean clean-hyper-nostr clean-secp clean-gnostr-git clean-tcl clean-jq

