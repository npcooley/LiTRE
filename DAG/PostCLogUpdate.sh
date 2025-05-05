#! /bin/bash

# print out log file updates and do some housekeeping
dateval=$(date)

# these are not xz compressed files, they're gz, but tar knows already...
# I need to keep better tabs on this...
# remove the tarball just because
rm comparisonlists.tar.xz

tmp1=$(mktemp)
total=0
shopt -s nullglob
tmp2=$(ls v*_comparisons_expected.txt | sort --version-sort)
for file in $tmp2; do
  count=$(grep -c ^ < ${file})
  ((total += count))
  echo "${count}" >> $tmp1
done

tmp3=$(tail -n 1 ${tmp1})
rm $tmp1

printf "  Node C Planned for %d comparisons, LiTRE has now planned %d total pairwise comparisons [${dateval}]\n" ${tmp3} ${count} >> SummaryFiles/log.txt

