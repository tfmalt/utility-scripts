#!/bin/bash

whereami() {
    DOMAIN=$(hostname -f | sed -n -e 's/^.*\.\(.*\..*\)$/\1/p')
    echo $DOMAIN
}
