
# Linux and MacOS specific setup
# Configuring dircolors
case $(uname) in
    Linux)
        if [ "$(setuptype)" != "linux-virtual" ]; then
            eval $(dircolors -b $HOME/.dircolors/dircolors.256dark)
        fi
        alias ls="ls --color=auto"
        eval $(dircolors -b $HOME/.dircolors/dircolors.256dark)
        ;;
    Darwin)
        export LSCOLORS=exGxcxdxbxefedabafacad
        ;;
esac
