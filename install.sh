#!/bin/zsh

ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=$ZSH/custom
THIS=$(readlink -f "$0")
ROOT=$(dirname "$THIS")
DOTFILES="$ROOT/dotfiles"
CONFIG="$ROOT/config"
PAD=24

# ---------------------------------------------------------------------------
echo "Setting up utility scripts ..."
# echo $SCRIPT
OUTPUT="source directory"
echo ${(l:$PAD:)OUTPUT}: $ROOT
OUTPUT="destination"
echo ${(l:$PAD:)OUTPUT}: $HOME

# ---------------------------------------------------------------------------
OUTPUT="setting up dircolors"
echo -n ${(l:$PAD:)OUTPUT}:
if [ ! -e $HOME/.dircolors ]; then
    ln -s $CONFIG/dircolors $HOME/.dircolors
    echo "$HOME/.dircolors"
else
    echo " exists"
fi

# ---------------------------------------------------------------------------
OUTPUT="setting up vim"
echo -n ${(l:$PAD:)OUTPUT}:
if [ ! -e $HOME/.vimrc ]; then
    ln -s $DOTFILES/vimrc $HOME/.vimrc
fi
if [ ! -e $HOME/.vim ]; then
    ln -s $DOTFILES/vim $HOME/.vim
fi
echo " Done"
# ---------------------------------------------------------------------------
OUTPUT="installing oh my zsh"
echo -n ${(l:$PAD:)OUTPUT}:

if [ ! -d "$ZSH" ]; then
    # sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone -c core.eol=lf -c core.autocrlf=false \
        -c fsck.zeroPaddedFilemode=ignore \
        -c fetch.fsck.zeroPaddedFilemode=ignore \
        -c receive.fsck.zeroPaddedFilemode=ignore \
        --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH" 2>&1 > /dev/null

    if [ $? -eq 0 ]; then
        echo " Done"
    else 
        echo " FAIL"
    fi
else
    echo " exists"
fi

# ---------------------------------------------------------------------------
OUTPUT="installing p10k theme"
echo -n ${(l:$PAD:)OUTPUT}: 

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    # Add powerlevel10k to the list of Oh My Zsh themes.
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k 2>&1 > /dev/null 

    if [ $? -eq 0 ]; then
        echo " Done"
    else 
        echo " FAIL"
    fi
else 
    echo " exists"
fi
# ---------------------------------------------------------------------------

OUTPUT="installing volta"
echo -n ${(l:$PAD:)OUTPUT}: 
if [ -e "$HOME/.volta" ]; then
    echo " exists"
else 
    curl -s https://get.volta.sh | bash -s -- --skip-setup
fi

OUTPUT="writing"
FILE=$HOME/.zshrc
echo ${(l:$PAD:)OUTPUT}: $FILE

cat > $FILE <<- EOD
export DOTFILES="$ROOT/dotfiles"
source \$DOTFILES/zshrc.sh
EOD

OUTPUT=""
echo "Testing shell ..."
echo ${(l:80::-:)}
exec zsh
