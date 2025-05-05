#! /bin/bash

# post-flight, remove the flight dag files and do some record keeping

# capture the current version of the dag and a set a few things
dateval=$(date)
# 3600 seconds in an hour: 7200 == 2hr, 14400 == 4hr, etc
# WatcherCount=14400
DAG="Flight.dag"
# LIM=100
other_vals01=$(tail -n 1 "TrackerFiles/VersionStart.txt") # this is the current version
other_vals01=$(echo "${other_vals01}" | cut -d " " -f1)
RESNAME="Flight"
lineval=$(tail -n 1 "TrackerFiles/DStart.txt")
iteration=$(echo $lineval | cut -d " " -f1)
res_target=$RESNAME$iteration

# relies on three standardized files and one tempfile
# comparisons completed is a simple txt file with all the completed comparisons
File01="v${other_vals01}_comparisons_completed.txt"
# a simple text file of all the expected comparisons
File02="v${other_vals01}_comparisons_expected.txt"
# a reference table for the VAR arguments
File03="v${other_vals01}_comparisons_planned.txt"
File04=$(mktemp)
File05=$(mktemp)

# collect current completed jobs
shopt -s nullglob
for file in Pairwise*.txt.gz; do
  if [[ -f $file && -s $file ]]; then
    printf '%s\n' $file
  fi
done > ${File04}

sort -u ${File04} > ${File05}
xargs <${File05} cat > ${res_target}.txt.gz
counts01=$(wc -l < ${File05})
counts02=$(wc -l < ${File02})

printf "    NodeDA DAG completed %d of %d jobs and is prepping for data transfer [${dateval}]\n" ${counts01} ${counts02} >> SummaryFiles/log.txt

# send current completed jobs to my data directory
RESYNC=1
ATTEMPTS=1
MAXRETRY=10
until [[ $RESYNC -eq 0 || $ATTEMPTS -eq $MAXRETRY ]]; do
  # attempt rsync
  # rsync -avu --progress --files-from=CurrentCompleteJobs.txt . /ospool/ap20/data/npcooley/RefSeqReps/${RESDIR}/
  rsync -avu --progress ${res_target}.txt.gz /ospool/ap20/data/npcooley/LiTRE/Pairs/
  # get exit status with $?
  # if the exit status
  
  RESYNC=$?
  if [[ $RESYNC -ne 0 ]]; then
    ((ATTEMPTS++))
    sleep 60
    echo $ATTEMPTS
  fi
done

if [ $RESYNC -ne 0 ]; then
  # if i did not transfer correctly after those attempts, nuke, because i'm about to delete all the data i just collected
  printf "    NodeDA DAG failed to transfer after %d attempts [${dateval}]\n" $ATTEMPTS >> SummaryFiles/log.txt
  exit 1
else
  # append completed jobs to the total list
  cat ${File05} >> ${File01}
  # remove files that have been copied over
  xargs rm <${File05}
  rm ${File04}
  rm ${File05}
  rm ${res_target}.txt.gz
  rm NodeD/NodeDA/out.*.err
  rm NodeD/NodeDA/out.*.out
  rm NodeD/NodeDA/out.*.log

  # remove the just completed dag's log files and things
  for file in NodeD/NodeDA/${DAG}*; do
    if [ -f $file ]; then
      rm $file
    fi
  done
  
  dateval=$(date)
  printf "    NodeDA DAG successfully tansferred results [${dateval}]\n" >> SummaryFiles/log.txt
  exit 0
fi



