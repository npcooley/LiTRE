#! /bin/bash

DateVal=$(date)
# post collection DAG
# nuke the associated DAG files and then ...
# AssembliesExpected.txt is a simple txt file with a single assembly file name per line
File01="AssembliesCompleted.txt"
# AssembliesComplete.txt is the same though is only populated by assemblies already collected
File02="AssembliesExpected.txt"

# collect current completed jobs
shopt -s nullglob
for file in Assembly*.RData; do
  [[ -f $file && -s $file ]] && printf '%s\n' "$file"
done > AssembliesCompleted.txt

# use redirection and wrap in parens so that the file name isn't printed
Completed=$(wc -l < "${File01}")
Expected=$(wc -l < "${File02}")

for file in /NodeB/NodeBA/${DAG}; do
  if [ -f $file ]; then
    rm $file
  fi
done

if [ ${Completed} -eq ${Expected} ]; then
  exit 0
else
  exit 1
fi

