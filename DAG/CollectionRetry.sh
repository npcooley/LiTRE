#! /bin/bash

dateval=$(date)

shopt -s nullglob
other_vals01=$(tail -n 1 "TrackerFiles/VersionStart.txt")
other_vals01=$(echo "${other_vals01}" | cut -d " " -f1)
other_vals02=$(tail -n 1 "TrackerFiles/BStart.txt")
RETRY=3
# post collection DAG
# nuke the associated DAG files and then ...
# AssembliesExpected.txt is a simple txt file with a single assembly file name per line
File01="v${other_vals01}_assemblies_completed.txt"
# AssembliesComplete.txt is the same though is only populated by assemblies already collected
File02="v${other_vals01}_assemblies_expected.txt"
# AssemplyPlanning.txt is a table of the expected VAR arguments for the dag
File03="v${other_vals01}_assemblies_planned.txt"

# use redirection and wrap in parens so that the file name isn't printed
Completed=$(wc -l < "${File01}")
Expected=$(wc -l < "${File02}")

# print an update to the logfile before exiting
printf "  NodeB completed %d of %d assemblies on attempt %d [${dateval}]\n" ${Completed} ${Expected} ${other_vals02} >> SummaryFiles/log.txt

# this needs to happen at the top most level
# the node inherits the exit condition of the post script, i think?
if [ ${Completed} -eq ${Expected} ]; then
  tar czvf assemblylists.tar.xz v*_assemblies_completed.txt
  exit 0
else
  if [ ${RETRY} -eq ${other_vals02} ]; then
    tar czvf assemblylists.tar.xz v*_assemblies_completed.txt
    exit 0
  fi
  exit 1
fi
