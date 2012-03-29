#!/bin/bash

DIR="."
if [ -d "$1" ]; then
    # echo "valid dir"
    DIR=$1
fi


MODULE_DEPS=$(
    find $DIR -name '*.pm' -exec grep '^use ' {} \;| \
    awk '{ if ($2 == "base") print $3; else if ($2 != "strict;") print $2 }'| \
    sed "s/[';]//g" | \
    sort | uniq
);

TEST_DEPS=$(
    find $DIR -name '*.t' -exec grep '^use ' {} \;| \
    awk '{ if ($2 == "base") print $3; else if ($2 != "strict;") print $2 }'| \
    sed "s/[';]//g" | \
    sort | uniq
);

for DEP in $MODULE_DEPS; do
    echo "requires '${DEP}';"
done;

for TEST in $TEST_DEPS; do
    echo "test_requires '${TEST}';"
done;
