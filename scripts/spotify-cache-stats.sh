#!/bin/bash

CACHEDIR="/var/lib/squeezeboxserver/cache/spotifycache/Storage"

cd "$CACHEDIR" || exit 1

clear
while true; do
    tput eo
    tput cup 0 0
    echo "Cache Size:      $(du -sh .)"
    dir_count=$(find . -maxdepth 1 -mindepth 1 ! -name 'index.dat' | wc -l)
    echo "Directory Count: ${dir_count}"
    tput el
    echo ""

    OPENFILES=$(sudo lsof +D "$CACHEDIR" 2>/dev/null | grep 'file$' | cut -d'/' -f8-)
    for FILE in $OPENFILES; do
        SIZE=$(stat -c %s "$CACHEDIR/$FILE")
        CTIME=$(stat -c %x "$CACHEDIR/$FILE")
        printf "File: %s %9s, Time: %s\n" "$FILE" "$SIZE" "$CTIME"
    done
    tput el
    echo ""

    mapfile -t recent_entries < <(
        find . -maxdepth 1 -mindepth 1 ! -name 'index.dat' -printf '%T@ %P\n' \
            | sort -n \
            | tail -n 10 \
            | awk '{print $2}'
    )
    for DIR in "${recent_entries[@]}"; do
        printf "%2s: %s,    " "$DIR" "$(du -sh "$DIR" | cut -f1)"
    done

    echo ""

    tput el
    for _ in {1..5}; do
        sleep 1
        echo -n "."
    done
    tput el1
done
