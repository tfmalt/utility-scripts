#!/bin/bash

git-checkout-date() {
    if [ "x$1" == "x" ]; then 
        echo "Usage: git-checkout-date <date> [<branch>]"
        return
    fi

    BRANCH=$2
    [ "x$BRANCH" == "x" ] && BRANCH=$(git branch | sed -n '/\* /s///p')
    [ "x$BRANCH" == "x" ] && return 

    CHECKSUM=$(git rev-list -n 1 --before=$1 $BRANCH)
    [ "x$CHECKSUM" == "x" ] && return

    echo input: $1 $BRANCH $CHECKSUM
    git checkout $CHECKSUM
}
