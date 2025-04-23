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
    if [[ $1 == "rm" || $1 == "uninstall" ]]
    then
        shift
        command brew rm "$@"
        deps=$(join <(brew leaves) <(brew deps $1))
        if [[ $deps != "" ]]
        then
            echo $deps
            command brew rm $deps
        fi
    else
        command brew "$@"
    fi
}

function ls() {
    if [[ $* == *l* ]]
    then
        if [ "$(uname)" == "Darwin" ]; then
            command ls -GhLa "$@"
        else
            command ls -GhLa --color "$@"
        fi
    else
        command ls "$@"
    fi
}

function cd() {
    command cd -P "$@" || return

    if [[ -d venv ]]
    then
        source venv/bin/activate
    fi

    if [[ $? -eq 0 ]]
    then
       ls -l
    else
        return $?
    fi
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
    if [[ $* == *.md* ]]
    then
        command mdcat "$@"
    else
        command ccat "$@"
    fi

    if [[ $? -eq 0 ]]
    then
        return $?
    else
        command cat "$@"
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

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh