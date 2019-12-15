# Useful code snippets

## Most commonly used commands

```bash
alias common="history | awk '{CMD[\$2]++;count++;}END { for (a in CMD)print CMD[a] \" \" CMD[a]/count*100 \"% \" a;}' | grep -v \"./\" | column -c3 -s \" \" -t | sort -nr | nl |  head"
```

## Get the largest folders of the current directory

```bash
du -ah * | sort -hr | head -n 20
```

## Clean out homebrew

A quick one liner to get rid of all homebrew installs for a clean start.

```bash
brew list -1 | xargs brew rm
```

## Print out a calendar for the current month

This comes as a built in function so there isn't anything that special but I didn't know about it and it's actually really cool so it gets a spot.

```bash
    cal
```

## An improved list directory

ls is my most used command so trying to improve it's output is a no-brainer. Not sure if I want to see that a link is symbolic or not so it may not be worth adding ```-L```.

```bash
function ls() {
    if [[ $* == *l* ]]
    then
        command ls -GhL "$@"
    else
        command ls "$@"
    fi
}
```

## On entering a directory activate any virtual environment and show files

Intuitively, I want to use symbolic links as shortcuts to get to useful directories. I feel like without ```cd -P``` the shell is lying to you.

```bash
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
        exit $?
    fi
}
```

## When using ```rm -r```, add the ```-f``` flag and then show files

```bash
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
        exit $?
    fi
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

A little extra work is done so that this line can run in the background and do so quietly.

```bash
(&>/dev/null find ~ -name ".DS_Store" -delete &)
```
