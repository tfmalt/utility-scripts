#!/bin/bash

countloc() {
    TYPES="js htm* css less php phtml inc *sh py"

    for EXT in $TYPES; do
        echo -n "    $EXT: "
        find . -type f -name '*.'"${EXT}"'' -print0 | xargs -0 cat | wc -l

    done
}
