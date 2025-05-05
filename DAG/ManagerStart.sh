#!/bin/bash

# each time this DAG is triggered
# either manually or through cron
# it needs to do a few things

val01=$(date)

# if the version tracker file exists append the iteration
if [ -e "TrackerFiles/VersionStart.txt" ]; then
  # file exists, append
  lineval=$(tail -n 1 "TrackerFiles/VersionStart.txt")
  iteration=$(echo $lineval | cut -d " " -f1)
  # totalcount=$(echo $lineval | cut -d ':' -f5)
  ((iteration++))
  val02=$(printf "%d $val01\n" $iteration)
  echo "$val02" >> TrackerFiles/VersionStart.txt
else
  # file file does not exist, create
  iteration=1
  val02=$(printf "%d $val01\n" $iteration)
  echo "$val02" > TrackerFiles/VersionStart.txt
fi

# if this file doesn't exist, create it
if [ ! -e "FTP_Key.txt" ] ; then
  touch "FTP_Key.txt"
fi

printf "[[${val01}]]: Manager.dag starting iteration %d\n" ${iteration} > SummaryFiles/log.txt

# just have a log files directory for each node
# LOGFILES=$(LogfilesAA LogFilesAB)
# # look for the log file directories
# if [ -d "" ]; then
#   
# else
#   
# fi

# create an iteration tracker
# echo "1" > IterationTracker.txt
# echo "1" > CollectionTracker.txt

# create a note for when the data was generated
# date > RunDates.txt

# build out the LogFile directories if they do not already exist
# mkdir -p LogFilesA LogFilesBA LogFilesBC LogFilesC LogFilesDA LogFilesDC
