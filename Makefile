.DEFAULT_GOAL := stub
bindir ?= ./build/bin
logdir ?= ./build/var/log
uname := $(shell uname -s)

clean: | uninstall

install: | stub
	@rsync -a src/ ${bindir}/
ifeq (${uname}, Darwin)
	@$(eval _bindir := $(shell greadlink -f ${bindir}))
	@$(eval _logdir := $(shell greadlink -f ${logdir}))
	@sed -i ''  "s|bindir=|bindir=${_bindir}|g" ${bindir}/somafm
	@sed -i ''  "s|logdir=|logdir=${_logdir}|g" ${bindir}/somafm
else ifeq (${uname}, Linux)
	@$(eval _bindir := $(shell readlink -f ${bindir}))
	@$(eval _logdir := $(shell readlink -f ${logdir}))
	@sed -i "s|bindir=|bindir=${_bindir}|g" ${bindir}/somafm
	@sed -i "s|logdir=|logdir=${_logdir}|g" ${bindir}/somafm
endif

stub:
	@mkdir -p ${bindir}
	@mkdir -p ${logdir}

test: | test-unit test-integration

test-integration: | install
	@bats test/integration

test-unit: | install
	@bats test/unit

uninstall:
	@rm -rf ${bindir}
	@rm -rf ${logdir}

.PHONY: clean install stub test test-integration test-unit uninstall
