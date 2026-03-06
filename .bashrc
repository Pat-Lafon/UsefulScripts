#!/bin/bash

alias python='python3'
alias pip='pip3'

#if [ "$(uname)" == "Darwin" ]; then
    #alias gcc='gcc-7'
    #alias cc='gcc-7'
    #alias g++='g++-7'
    #alias c++='g++-7'
#fi

if [[ -d ~/.linuxbrew ]]; then
    eval "$(/home/pwl45/.linuxbrew/bin/brew shellenv)"
fi

alias duck='{ du -ha | sort -rh | head -20;} 2> /dev/null'

alias common="history | awk '{CMD[\$2]++;count++;}END { for (a in CMD)print CMD[a] \" \" CMD[a]/count*100 \"% \" a;}' |\
 grep -v \"./\" | column -c3 -s \" \" -t | sort -nr | nl | head"

# This makes some assumptions about the ordering of arguments that may not be true
function brew() {
    if [[ $1 == "rm" || $1 == "uninstall" ]]; then
        local pkg="$2"  # Save package name before shift
        shift
        command brew rm "$@"

        # Only check deps if we actually removed something successfully
        if [[ $? -eq 0 && -n "$pkg" ]]; then
            local deps=$(join <(brew leaves) <(brew deps "$pkg") 2>/dev/null)
            if [[ -n "$deps" ]]; then
                echo "Removing unused dependencies: $deps"
                command brew rm $deps
            fi
        fi
    else
        command brew "$@"
    fi
}

function git() {
    if [[ "$1" == "push" && "$*" == *"--force"* ]]; then
        # Replace --force with --force-with-lease in the command line
        local cmd_line="$*"
        cmd_line="${cmd_line// --force/ --force-with-lease}"
        eval "command git $cmd_line"
    else
        command git "$@"
    fi
}

function ls() {
    if [[ $* == *l* ]]; then
        if [[ "$(uname)" == "Darwin" ]]; then
            command ls -GhLa "$@"
        else
            command ls -GhLa --color=auto "$@"
        fi
    else
        command ls "$@"
    fi
}

function cd() {
    command cd -P "$@" || return

    # Auto-activate venv if present
    if [[ -d venv ]]; then
        source venv/bin/activate
    fi

    # Always ls after successful cd (the $? check is redundant here)
    ls -l
}

function rm() {
    if [[ $* == *r* ]]
    then
        command rm -f "$@"
    else
        command rm "$@"
    fi

    if [[ $? -eq 0 ]]
    then
       ls -l
    else
        return $?
    fi
}

function cat() {
    if [[ $* == *.md* ]]; then
        command mdcat "$@" 2>/dev/null || command cat "$@"
    else
        command ccat "$@" 2>/dev/null || command cat "$@"
    fi
}

function extract() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
	    echo "$1" is not a valid file
    fi
}

function gh() {
    if [[ "$1" == "repo" && "$2" == "clone" ]]; then
        command gh "$@"
        local exit_code=$?

        if [[ $exit_code -eq 0 ]]; then
            # Find the repo argument (first non-flag, non-subcommand arg)
            local repo_arg=""
            for arg in "${@:3}"; do
                if [[ "$arg" != -* ]]; then
                    repo_arg="$arg"
                    break
                fi
            done

            if [[ -n "$repo_arg" ]]; then
                local repo_name=$(basename "$repo_arg" .git)
                if [[ -d "$repo_name" ]]; then
                    (
                        cd "$repo_name" || exit 1
                        # Get the repository from the origin remote and set it explicitly
                        local origin_url=$(git remote get-url origin 2>/dev/null)
                        if [[ -n "$origin_url" ]]; then
                            # Extract owner/repo from the URL
                            local repo_path=""
                            case "$origin_url" in
                                *github.com*)
                                    repo_path=$(echo "$origin_url" | sed -E 's|.*github\.com[:/]([^/]+/[^/]+)(\.git)?.*|\1|')
                                    ;;
                            esac

                            if [[ -n "$repo_path" ]]; then
                                command gh repo set-default "$repo_path" 2>/dev/null || true
                            else
                                command gh repo set-default 2>/dev/null || true
                            fi
                        fi
                    )
                fi
            fi
        fi

        return $exit_code
    else
        command gh "$@"
    fi
}

function gh() {
    if [[ "$1" == "repo" && "$2" == "clone" ]]; then
        command gh "$@"
        local exit_code=$?

        if [[ $exit_code -eq 0 ]]; then
            local repo_arg=""
            for arg in "${@:3}"; do
                if [[ "$arg" != -* ]]; then
                    repo_arg="$arg"
                    break
                fi
            done

            if [[ -n "$repo_arg" ]]; then
                local repo_name=$(basename "$repo_arg" .git)
                if [[ -d "$repo_name" ]]; then
                    cd "$repo_name" || return 1
                    command gh repo set-default "$repo_arg" 2>/dev/null || true
                fi
            fi
        fi

        return $exit_code
    else
        command gh "$@"
    fi
}

## Need something like this for atuin
source ~/.bash-preexec.sh
eval "$(atuin init bash)"
