act-install:submodules## install act from deps/act/install.sh -b
	./deps/act/install.sh -b /usr/local/bin && exec bash
ubuntu-git:submodules docker-start## 	run act in .github
	#we use -b to bind the repo to the act container
	#in the single dep instances we reuse (-r) the container
	@type -P act && export $(cat ~/gh_token.txt) && act -vb -W $(PWD)/.github/workflows/$@.yml || $(MAKE) act-install
.PHONY:deps/jq/.github/workflows/linux ubuntu-jq
#ubuntu-jq:submodules docker-start jq/.github/workflows/linux## 	run act for deps/jq/.github/workflows/linux.yml
ubuntu-jq:submodules docker-start## 	run act .github/workflows/ubuntu-jq.yml
	#@pushd deps/jq && autoreconf -i && ./configure  --disable-maintainer-mode  && make all install
	@type -P act && export ACTIONS_RUNTIME_TOKEN=$(cat ~/gh_token.txt) && act -vb -W $(PWD)/.github/workflows/$@.yml || $(MAKE) act-install
jq/.github/workflows/linux:submodules docker-start## 	
	#we use -b to bind the repo to the act container
	#in the single dep instances we reuse (-r) the container
	#@type -P act && export ACTIONS_RUNTIME_TOKEN=$(cat ~/gh_token.txt) && act -vb -C deps  -W $@.yml || $(MAKE) act-install
ubuntu-nostcat:submodules docker-start## 	run act in .github
	#we use -b to bind the repo to the act container
	#in the single dep instances we reuse (-r) the container
	@type -P act && export $(cat ~/gh_token.txt) && act -vb -W $(PWD)/.github/workflows/$@.yml || $(MAKE) act-install
	#the matrix/pre/release builds are for the resulting app builds
ubuntu-matrix:submodules docker-start## 	run act in .github
	@type -P act && export $(cat ~/gh_token.txt) && act -vb -W $(PWD)/.github/workflows/$@.yml || $(MAKE) act-install
