#! /bin/bash

args01=$1
args02=$2

# .*description0*: Match everything up to "description" and optional leading zeroes
# ([0-9]+): Capture the number after leading zeroes
# ext.*: Ignore the rest
# \1: Only output the first capture group

sed -E 's/.*description0*([0-9]+)ext.*/\1/' ${args01} > ${args02}
