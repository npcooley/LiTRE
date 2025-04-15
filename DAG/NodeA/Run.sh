#!/bin/bash

Rscript Run.R 

if [ -e AssembliesExpected.txt ]
then
  exit 0
else
  exit 1
fi
