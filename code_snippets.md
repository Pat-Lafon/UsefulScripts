# Useful code snippets

## Most commonly used commands

```bash
alias common="history | awk '{CMD[\$2]++;count++;}END { for (a in CMD)print CMD[a] \" \" CMD[a]/count*100 \"% \" a;}' | grep -v \"./\" | column -c3 -s \" \" -t | sort -nr | nl |  head"
```

## Get the largest folders of the current directory

```bash
du -ah * | sort -hr | head -n 20
```

## On entering a directory activate venv and show files

```bash
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
```

## When using ```rm -r```, add the ```-f``` flag and then show files

```bash
function rm() {
    if [[ $* == *-r* ]]
    then
        command rm -f "$@"
    else
        command rm "$@"
    fi
    ls -l
}
```

## Function to open compressed files

```bash
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
```

## Resize terminal

```bash
printf '\033[8;<height>;<width>t'
printf '\033[8;25;100t'
```

## Remove .DS_Store files

```bash
find ~ -name ".DS_Store" -delete 2>/dev/null &
```
