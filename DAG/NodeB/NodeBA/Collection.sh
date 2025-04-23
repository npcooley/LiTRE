#!/bin/bash

Rscript Collection.R ${1} ${2} ${3}

# always exit gracefully,
# if the Rscript exits 1, this shell script should inherit that exit condition,
# so we force it to zero and let the DAG manage it
exit 0

