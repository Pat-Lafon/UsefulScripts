printf '\033[8;25;100t'

alias python='python3'
alias pip='pip3'

eval $(thefuck --alias)
alias f="fuck"

alias common="history | awk '{CMD[\$2]++;count++;}END { for (a in CMD)print CMD[a] \" \" CMD[a]/count*100 \"% \" a;}' |\
 grep -v \"./\" | column -c3 -s \" \" -t | sort -nr | nl | head"

function ls() {
    if [[ $* == *-l* ]]
    then
        command ls -GhL "$@"
    else
        command ls "$@"
    fi
}

ls -l

function cd() {
    command cd "$@" || return

    if [[ -d venv ]]
    then
        source venv/bin/activate
    fi
    ls -l
}

function rm() {
    if [[ $* == *-r* ]]
    then
        command rm -f "$@"
    else
        command rm "$@"
    fi
    ls -l
}

function extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
	    echo $1 is not a valid file
    fi
}

(&>/dev/null find ~ -name ".DS_Store" -delete &)
