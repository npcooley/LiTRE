#!/bin/bash

Rscript SetTotalJobs.R

if [ -e PlannedJobs.txt ]
then
  exit 0
else
  exit 1
fi
