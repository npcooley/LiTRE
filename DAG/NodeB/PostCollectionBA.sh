#! /bin/bash

dateval=$(date)

other_vals01=$(tail -n 1 "TrackerFiles/VersionStart.txt")
other_vals01=$(echo "${other_vals01}" | cut -d " " -f1)

LIM=3
DAG="Collection.dag"
# post collection DAG
# nuke the associated DAG files and then ...
# AssembliesExpected.txt is a simple txt file with a single assembly file name per line
File01="v${other_vals01}_assemblies_completed.txt"
# AssembliesComplete.txt is the same though is only populated by assemblies already collected
File02="v${other_vals01}_assemblies_expected.txt"
# AssemplyPlanning.txt is a table of the expected VAR arguments for the dag
File03="v${other_vals01}_assemblies_planned.txt"

# collect current completed jobs
shopt -s nullglob
for file in Assembly*.RData; do
  [[ -f $file && -s $file ]] && printf '%s\n' "$file"
done > "${File01}"

# use redirection and wrap in parens so that the file name isn't printed
Completed=$(wc -l < ${File01})
Expected=$(wc -l < ${File02})

printf "    NodeBA DAG completed %d of %d jobs returning data [${dateval}]" ${Completed} ${Expected} >> SummaryFiles/log.txt

for file in NodeB/NodeBA/${DAG}*; do
  if [ -f $file ]; then
    rm $file
  fi
done


if [ -e "TrackerFiles/BEnd.txt" ]; then
  lineval=$(tail -n 1 "TrackerFiles/BEnd.txt")
  iteration=$(echo $lineval | cut -d " " -f1)
  # totalcount=$(echo $lineval | cut -d ':' -f5)
  ((iteration++))
  printf "$iteration\n" >> TrackerFiles/BEnd.txt
else
  iteration=1
  printf "$iteration\n" > TrackerFiles/BEnd.txt
fi

# this needs to happen at the top most level
# if [ ${Completed} -eq ${Expected} ]; then
#   exit 0
# else
#   exit 1
# fi

