#! /bin/bash

# post A node
# check the assemblies expected and print a line into the log file
val01=$(tail -n 1 TrackerFiles/VersionStart.txt)
val01=$(echo "${val01}" | cut -d " " -f1)
file01="v${val01}_assemblies_expected.txt"

val02=$(wc -l ${file01})

printf "  Node A planned %s jobs\n" $val02 >> SummaryFiles/log.txt

