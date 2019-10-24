# .bash_profile

export PATH=${PATH}:/usr/textbin
export PATH="/usr/local/sbin:$PATH"
export BASH_SILENCE_DEPRECATION_WARNING=1

if [ -f .bashrc ]; then
    . .bashrc
fi

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi