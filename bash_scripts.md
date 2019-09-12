### Most commonly used commands
```alias common="history | awk '{CMD[\$2]++;count++;}END { for (a in CMD)print CMD[a] \" \" CMD[a]/count*100 \"% \" a;}' | grep -v \"./\" | column -c3 -s \" \" -t | sort -nr | nl |  head"```

### Get the largest folders of the current directory
```du -ah * | sort -hr | head -n 20```

### On entering a directory activate venv and show files
```
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

### Resize terminal
``` printf '\033[8;<height>;<width>t' ```
``` printf '\033[8;25;100t' ```
