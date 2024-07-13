.PHONY: install uninstall

install: uninstall
	@./scripts/install.sh

uninstall:
	@./scripts/uninstall.sh
