#!/bin/bash

Rscript Run.R 

shopt -s nullglob
count=0
for file in v*_assemblies_expected.txt; do
  if [ -e $file ]; then
    ((count++))
    if [ $count -gt 0 ]; then
      exit 0
    fi
  fi
done
exit 1
