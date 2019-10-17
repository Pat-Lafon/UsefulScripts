# .bash_profile

export PATH=${PATH}:/usr/textbin
export PATH="/usr/local/sbin:$PATH"

if [ -f .bashrc ]; then
    . .bashrc
fi

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi