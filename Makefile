setup:
	./bootstrap.sh

reload:
	brew leaves > brew_leaves.txt
	brew list --casks > brew_casks.txt
	code --list-extensions > vscode_extensions.txt
