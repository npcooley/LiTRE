#!/bin/bash

# end conditions when the last node is the comparisons node
# the dag ends completely when either all the retries are hit, or all the expected
# comparisons are generated

# capture the current version of the dag and a set a few things
dateval=$(date)

other_vals01=$(tail -n 1 "TrackerFiles/VersionStart.txt") # this is the current version
other_vals01=$(echo "${other_vals01}" | cut -d " " -f1)
# relies on three standardized files and one tempfile
# comparisons completed is a simple txt file with all the completed comparisons
File01="v${other_vals01}_comparisons_completed.txt"
# a simple text file of all the expected comparisons
File02="v${other_vals01}_comparisons_expected.txt"
# a reference table for the VAR arguments
File03="v${other_vals01}_comparisons_planned.txt"

# grab the recording of the total number of times the D node has been tried
other_vals02=$(tail -n 1 "TrackerFiles/DStart.txt")
other_vals02=$(echo $other_vals02 | cut -d " " -f1)
other_vals03=$(wc -l < $File01)
other_vals04=$(wc -l < $File02)
LIM=350
DAG="Flight.dag"

for file in NodeD/NodeDA/${DAG}*; do
  if [ -f $file ]; then
    rm $file
  fi
done

# if i have reached the limit of flights, or i've captured all comparisons, end
# else keep going
if [ $other_vals02 -ge $LIM ] || [ $other_vals03 -eq $othervals_04 ]; then
  
  # manage the tracker files
  if [ -e "TrackerFiles/VersionComplete.txt"]; then
    # file tracker exists, append the new flight numeric identifier and date
    # file exists, append
    lineval=$(tail -n 1 "TrackerFiles/VersionComplete.txt")
    iteration=$(echo $lineval | cut -d " " -f1)
    # totalcount=$(echo $lineval | cut -d ':' -f5)
    ((iteration++))
    printf "%d\n" ${iteration} > TrackerFiles/VersionComplete.txt
  else
    # file tracker does not exist, create it with the numeric identifier '1' and the date
    iteration=1
    printf "%d\n" ${iteration} > TrackerFiles/VersionComplete.txt
  fi
  # add to the log file and remove some of the trackerfiles
  rm TrackerFiles/DStart
  printf "[[${dateval}]]: Manager.dag ending iteration %d\n" ${iteration} >> SummaryFiles/log.txt
  # exit with condition zero, the dag is completed
  exit 0
else
  printf "  Node D completed %d of %d comparisons and is retrying [${dateval}]\n" ${other_vals03} ${other_vals04} >> SummaryFiles/log.txt
  # exit with 1, the dag node failed, and will retry within it's specifications
  exit 1
fi


