#!/bin/bash

# create an iteration tracker
echo "1" > IterationTracker.txt
echo "1" > CollectionTracker.txt

# create a note for when the data was generated
date > RunDates.txt

# build out the LogFile directories if they do not already exist
mkdir -p LogFilesA LogFilesBA LogFilesBC LogFilesC LogFilesDA LogFilesDC


if [ ! -e "FTP_Key.txt" ] ; then
  touch "FTP_Key.txt"
fi

