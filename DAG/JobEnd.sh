#!/bin/bash


# i will eventually add this to the end condition, but i'm keeping it here for a hot second
if [ -e "TrackerFiles/VersionComplete.txt"]; then
  # file tracker exists, append the new flight numeric identifier and date
  # file exists, append
  iteration=$(tail -n 1 "TrackerFiles/VersionComplete.txt")
  ((iteration++))
  val02=$(printf "$iterartion:$val01\n")
  echo "$val02" >> TrackerFiles/VersionComplete.txt
else
  # file tracker does not exist, create it with the numeric identifier '1' and the date
  iteration=1
  val02=$(printf "$iterartion:$val01\n")
  echo "$val02" > TrackerFiles/VersionComplete.txt
fi

