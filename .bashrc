printf '\033[8;25;100t'

alias python='python3'
alias pip='pip3'
eval $(thefuck --alias)
alias f="fuck"

alias common="history | awk '{CMD[\$2]++;count++;}END { for (a in CMD)print CMD[a] \" \" CMD[a]/count*100 \"% \" a;}' |\
 grep -v \"./\" | column -c3 -s \" \" -t | sort -nr | nl | head"

function cd() {
    command cd "$@" || return

    if [[ -d venv ]]
    then
        source venv/bin/activate
        ls -l
    else
        ls -l
    fi
}

(&>/dev/null find ~ -name ".DS_Store" -delete &)