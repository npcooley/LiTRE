#!/bin/bash

# each time this DAG is triggered
# either manually or through cron
# it needs to do a few things

val01="$(date)"

# if the version tracker file exists append the iteration
if [ -e "TrackerFiles/VersionStart.txt" ]; then
  # file exists, append
  iteration=$(tail -n 1 "TrackerFiles/VersionStart.txt")
  ((iteration++))
  val02=$(printf "$iterartion:$val01\n")
  echo "$val02" >> TrackerFiles/VersionStart.txt
else
  # file file does not exist, create
  iteration=1
  val02=$(printf "$iterartion:$val01\n")
  echo "$val02" > TrackerFiles/VersionStart.txt
fi



# i will eventually add this to the end condition, but i'm keeping it here for a hot second
if [ -e "TrackerFiles/VersionComplete.txt"]; then
  # file tracker exists, append the new flight numeric identifier and date
else
  # file tracker does not exist, create it with the numeric identifier '1' and the date
fi

# create an iteration tracker
# echo "1" > IterationTracker.txt
# echo "1" > CollectionTracker.txt

# create a note for when the data was generated
# date > RunDates.txt

# build out the LogFile directories if they do not already exist
# mkdir -p LogFilesA LogFilesBA LogFilesBC LogFilesC LogFilesDA LogFilesDC


if [ ! -e "FTP_Key.txt" ] ; then
  touch "FTP_Key.txt"
fi

