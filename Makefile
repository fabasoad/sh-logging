.PHONY: cleanup install uninstall link unlink

BIN ?= fabasoad
PREFIX ?= /usr/local
CMDS = log log-init

current_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

cleanup:
	@for cmd in $(CMDS); do rm -f $(PREFIX)/bin/$(BIN)-$${cmd}; done

install: cleanup
	@for cmd in $(CMDS); do cp "$(current_dir)lib/$(BIN)-$${cmd}.sh" $(PREFIX)/bin/$(BIN)-$${cmd}; done
	@echo "Operation completed successfully: install"

uninstall: cleanup
	@echo "Operation completed successfully: uninstall"

link: cleanup
	@for cmd in $(CMDS); do ln -s "$(current_dir)lib/$(BIN)-$${cmd}.sh" $(PREFIX)/bin/$(BIN)-$${cmd}; done
	@echo "Operation completed successfully: link"

unlink: cleanup
	@echo "Operation completed successfully: unlink"

