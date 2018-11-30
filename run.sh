#!/bin/bash

# Build a hmm for each file ending in .fa(sta) from alignment folder
for i in $(find alignments/ -type f | grep "\.fa")
do
    date +"[%Y-%m-%d %H:%M:%S] Started '${i}'"

    # generate the hmm name
    HMMNAME=$(basename ${i} | sed 's/\.fa[^.]*//').hmm

    # build the hmm
    hmmbuild hmms/"${HMMNAME}" "${i}"

    date +"[%Y-%m-%d %H:%M:%S] Finished '${i}'"
done

