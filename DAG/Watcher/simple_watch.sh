#! /bin/bash

# ENSURE THIS SCRIPT IS EXECUTABLE BEFORE PUSHING!!

# Service script:
# executable = ./Watcher/simple_watch.sh
# arguments = PLACEHOLDER

# The DAG constructors specifically look for that PLACEHOLDER keyword and edit it
# during construction

# this is a service script, the DAG should terminate it if all the jobs on the current
# flight complete as expected, if not, maybe write a note into the log and exit with a condition
# that tells the service to abort the DAG

sleep $1

dateval=$(date)
printf "      NodeDA terminated by watcher script after %d seconds [${dateval}]\n" $1 >> SummaryFiles/log.txt

exit 2
