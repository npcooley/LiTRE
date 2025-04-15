#!/bin/bash

# end conditions when the last node is the comparisons node
# either end when all comparisons have been completed
# OR no new comparisons have been added ... if this blows up from the OSG side we just have to
# retrigger the manager manually -- should be fine?

VAR1="$(date)"
VAR2=$(wc -l < PlannedJobs.txt)
VAR3=$(wc -l < CompletedJobs.txt)
VAR4=$(wc -l < CurrentCompleteJobs.txt)

# If i have completed all potential jobs, OR some number of most recent flights
# haven't completed any jobs
if [[ "$VAR2" -eq "$VAR3" ]]; then
  if [ -e "TrackerFiles/VersionComplete.txt"]; then
    # file tracker exists, append the new flight numeric identifier and date
    # file exists, append
    lineval=$(tail -n 1 "TrackerFiles/VersionComplete.txt")
    iteration=$(echo $lineval | cut -d ':' -f1)
    # totalcount=$(echo $lineval | cut -d ':' -f5)
    ((iteration++))
    VAR5=$(printf "$iteration:$VAR1:$VAR3\n")
    echo "$VAR5" >> TrackerFiles/VersionComplete.txt
  else
    # file tracker does not exist, create it with the numeric identifier '1' and the date
    iteration=1
    VAR5=$(printf "$iterartion:$VAR1:$VAR3\n")
    echo "$VAR5" > TrackerFiles/VersionComplete.txt
  fiL
  echo 'Complete!'
  exit 0
else
  echo 'Not Complete!'
  # in the current case, this script checks at the end of D every time, and triggers the retry statement
  # so we need to prepare to nuke the prior iteration's dag files before letting the next one start up
  rm NodeD/Run.dag.*
  exit 1
fi

if [ -e "TrackerFiles/VersionComplete.txt"]; then
  # file tracker exists, append the new flight numeric identifier and date
  # file exists, append
  lineval=$(tail -n 1 "TrackerFiles/VersionComplete.txt")
  iteration=$(echo $lineval | cut -d ':' -f1)
  # totalcount=$(echo $lineval | cut -d ':' -f5)
  ((iteration++))
  VAR5=$(printf "$iteration:$VAR1:$VAR3\n")
  echo "$VAR5" >> TrackerFiles/VersionComplete.txt
else
  # file tracker does not exist, create it with the numeric identifier '1' and the date
  iteration=1
  VAR5=$(printf "$iterartion:$VAR1:$VAR3\n")
  echo "$VAR5" > TrackerFiles/VersionComplete.txt
fi

# add anything else that needs to be cleaned up upon completion

# there's no auto-retriggering of the whole manager outside of cron
# nuke the manager dag files\
rm Manager.dag.*

# if [[ "$VAR2" -eq "$VAR3" ]]; then
#   echo 'Complete!'
#   exit 0
# else
#   echo 'Not Complete!'
#   rm Comparisons.dag.*
#   exit 1
# fi


