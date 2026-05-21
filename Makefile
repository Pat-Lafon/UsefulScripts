.PHONY: setup reload link

setup:
	./bootstrap.sh

reload:
	brew leaves > brew_leaves.txt
	brew list --casks > brew_casks.txt
	brew tap | grep -v '^homebrew/' > brew_cask_taps.txt
	@if command -v code >/dev/null 2>&1; then \
		code --list-extensions > vscode_extensions.txt; \
	else \
		echo "skipping vscode_extensions.txt (code not installed)"; \
	fi
	@if command -v npm >/dev/null 2>&1; then \
		npm ls -g --depth=0 --parseable | tail -n +2 | awk -F/ '{print $$NF}' | sort | grep -v '^npm$$' > npm_globals.txt; \
	else \
		echo "skipping npm_globals.txt (npm not installed)"; \
	fi
	@if command -v cargo >/dev/null 2>&1; then \
		cargo install --list | grep -E '^[a-zA-Z0-9_-]+ v[0-9].*:$$' | grep -v '(' | awk '{print $$1}' | grep -vxE 'miri|rust-analyzer|rustfmt|clippy' | sort > cargo_installs.txt; \
	else \
		echo "skipping cargo_installs.txt (cargo not installed)"; \
	fi

link:
	./link.sh
