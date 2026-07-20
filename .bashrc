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
alias c='claude'

alias duck='{ du -ha | sort -rh | head -20;} 2> /dev/null'

alias common="history | awk '{CMD[\$2]++;count++;}END { for (a in CMD)print CMD[a] \" \" CMD[a]/count*100 \"% \" a;}' |\
 grep -v \"./\" | column -c3 -s \" \" -t | sort -nr | nl | head"

function brew() {
    if [[ $1 == "rm" || $1 == "uninstall" ]]; then
        local pkg="$2"
        shift
        command brew rm "$@"

        # Only check deps if we actually removed something successfully
        if [[ $? -eq 0 && -n "$pkg" ]]; then
            local -a deps
            mapfile -t deps < <(join <(command brew leaves) <(command brew deps "$pkg") 2>/dev/null)
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
        local -a args=()
        local arg
        for arg in "$@"; do
            if [[ "$arg" == "--force" ]]; then
                args+=("--force-with-lease")
            else
                args+=("$arg")
            fi
        done
        command git "${args[@]}"
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
        command ls -GhLa "$@"
    else
        command ls "$@"
    fi
}

function rm() {
    local arg recursive=0
    for arg in "$@"; do
        case "$arg" in
            --recursive) recursive=1; break ;;
            --*) ;;
            -*[rR]*) recursive=1; break ;;
        esac
    done
    local rc
    if (( recursive )); then
        local target abs_target check_dir repo_root dirty=()
        for target in "$@"; do
            [[ $target == -* ]] && continue
            [[ ! -e $target ]] && continue
            if [[ $target == /* ]]; then
                abs_target=$target
            else
                abs_target=$PWD/$target
            fi
            if [[ -d $abs_target ]]; then
                check_dir=$abs_target
            else
                check_dir=${abs_target%/*}
                [[ -z $check_dir ]] && check_dir=/
            fi
            repo_root=$(command git -C "$check_dir" rev-parse --show-toplevel 2>/dev/null) || continue
            if [[ -n "$(command git -C "$repo_root" status --porcelain -- "$abs_target" 2>/dev/null)" ]]; then
                dirty+=("$target")
            fi
        done
        if (( ${#dirty[@]} > 0 )); then
            echo "rm: uncommitted git changes in:" >&2
            printf '  %s\n' "${dirty[@]}" >&2
            if [[ -t 0 ]]; then
                local reply
                read -r -p "Proceed anyway? [y/N] " reply
                [[ $reply =~ ^[Yy]$ ]] || { echo "Aborted." >&2; return 1; }
            fi
        fi
        command rm -f "$@"
        rc=$?
    else
        command rm "$@"
        rc=$?
    fi
    (( rc == 0 )) && ls -l
    return $rc
}

if command -v bat >/dev/null; then
    function cat() {
        command bat --style=plain --paging=never "$@"
    }
fi

function extract() {
    if [[ -f "$1" ]]; then
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
        echo "'$1' is not a valid file"
    fi
}

function gh() {
    if [[ "$1" == "repo" && "$2" == "clone" ]]; then
        command gh "$@"
        local exit_code=$?

        if [[ $exit_code -eq 0 ]]; then
            # First non-flag arg after "clone" is the repo identifier; the second
            # (if present, before "--") is an explicit target directory.
            local repo_arg="" target_arg="" arg
            for arg in "${@:3}"; do
                [[ "$arg" == "--" ]] && break
                [[ "$arg" == -* ]] && continue
                if [[ -z "$repo_arg" ]]; then
                    repo_arg="$arg"
                else
                    target_arg="$arg"
                    break
                fi
            done

            if [[ -n "$repo_arg" ]]; then
                local clone_dir
                if [[ -n "$target_arg" ]]; then
                    clone_dir="$target_arg"
                else
                    clone_dir=$(basename "$repo_arg" .git)
                fi
                if [[ -d "$clone_dir" ]] && cd "$clone_dir"; then
                    # Derive owner/repo from origin so set-default works regardless
                    # of which form the user passed to clone (owner/repo, https://, git@…)
                    local origin_url
                    origin_url=$(git remote get-url origin 2>/dev/null)
                    if [[ "$origin_url" =~ github\.com[:/]([^/]+/[^/]+?)(\.git)?$ ]]; then
                        command gh repo set-default "${BASH_REMATCH[1]}" 2>/dev/null
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
command -v starship >/dev/null && eval "$(starship init bash)"
command -v atuin >/dev/null && eval "$(atuin init bash)"
