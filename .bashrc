#!/bin/bash

# Only apply for interactive shells. Aliases, functions, prompt hooks, and
# atuin/starship don't make sense in non-interactive bash.
[[ $- == *i* ]] || return

# -------------- History Configuration --------------
export HISTCONTROL=erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTIGNORE="ls:ll:cd:pwd:exit:clear:history"

alias python='python3'
alias pip='pip3'

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
            local -a deps
            mapfile -t deps < <(join <(brew leaves) <(brew deps "$pkg") 2>/dev/null)
            if (( ${#deps[@]} > 0 )); then
                echo "Removing unused dependencies: ${deps[*]}"
                command brew rm "${deps[@]}"
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
    local arg long=0
    for arg in "$@"; do
        if [[ $arg == -[!-]*l* ]]; then
            long=1
            break
        fi
    done
    if (( long )); then
        if [[ "$(uname)" == "Darwin" ]]; then
            command ls -GhLa "$@"
        else
            command ls -GhLa --color=auto "$@"
        fi
    else
        command ls "$@"
    fi
}

function rm() {
    local arg recursive=0
    for arg in "$@"; do
        if [[ $arg == -[!-]*r* || $arg == -[!-]*R* || $arg == --recursive ]]; then
            recursive=1
            break
        fi
    done
    if (( recursive )); then
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
    command bat --style=plain --paging=never "$@" 2>/dev/null || command cat "$@"
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
            # First non-flag arg after "clone" is the repo identifier
            local repo_arg=""
            for arg in "${@:3}"; do
                if [[ "$arg" != -* ]]; then
                    repo_arg="$arg"
                    break
                fi
            done

            if [[ -n "$repo_arg" ]]; then
                local repo_name
                repo_name=$(basename "$repo_arg" .git)
                if [[ -d "$repo_name" ]] && cd "$repo_name"; then
                    # Derive owner/repo from origin so set-default works regardless
                    # of which form the user passed to clone (owner/repo, https://, git@…)
                    local origin_url
                    origin_url=$(git remote get-url origin 2>/dev/null)
                    if [[ "$origin_url" == *github.com* ]]; then
                        local repo_path
                        repo_path=$(echo "$origin_url" | sed -E 's|.*github\.com[:/]([^/]+/[^/]+)(\.git)?.*|\1|')
                        [[ -n "$repo_path" ]] && command gh repo set-default "$repo_path" 2>/dev/null || true
                    fi
                fi
            fi
        fi

        return $exit_code
    else
        command gh "$@"
    fi
}

# -------------- Per-shell tool initialization --------------
# These hook into PROMPT_COMMAND / keybindings / PS1, which are shell-local —
# they must run in every interactive shell, not just login shells. Hence .bashrc.
[ -x "$(command -v starship)" ] && eval "$(starship init bash)"
[ -x "$(command -v atuin)" ] && eval "$(atuin init bash)"
