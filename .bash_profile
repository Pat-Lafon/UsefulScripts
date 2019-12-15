# .bash_profile

export PATH=${PATH}:/usr/textbin
export PATH="/usr/local/sbin:$PATH"

if [ "$(uname)" == "Darwin" ]; then
    export BASH_SILENCE_DEPRECATION_WARNING=1
fi

printf '\033[8;25;100t'

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

ls -l

if [ "$(uname)" == "Darwin" ]; then
    (&>/dev/null find ~ -name ".DS_Store" -delete &)
fi
