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
        command git push "${@/--force/--force-with-lease}"
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