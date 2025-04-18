#!/bin/bash

Rscript Collection.R ${1} ${2} ${3}

# let the DAG manage job failure or success at the node
# if [ -e Assembly*.RData ]
# then
#   exit 0
# else
#   exit 1
# fi

