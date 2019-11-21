# .bash_profile

export PATH=${PATH}:/usr/textbin
export PATH="/usr/local/sbin:$PATH"
export BASH_SILENCE_DEPRECATION_WARNING=1

printf '\033[8;25;100t'

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

#ls -l

rm .bash_history .python_history

(&>/dev/null find ~ -name ".DS_Store" -delete &)
