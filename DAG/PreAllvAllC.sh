#! /bin/bash

dateval=$(date)
# preplanning, tar all the 'vX_assemblies_completed.txt' files into one
# and tar all the 'vX_planned_comparisons.txt' files into one

shopt -s nullglob
count=0
for file in v*_comparisons_expected.txt; do
  ((count++))
done

# there *should* always be at least one assemblies completed file,
# but if this is the first iteration of the pipeline, there won't be any planned comparisons
# yet
((count++))
touch "v${count}_comparisons_expected.txt"
tar czvf comparisonlists.tar.xz v*_comparisons_expected.txt

# print some messages to the log file

printf "  Node C beginning all-vs-all planning stage [${dateval}]\n" >> SummaryFiles/log.txt
