#! /bin/bash

DateVal=$(date)
# 3600 seconds in an hour: 7200 == 2hr, 14400 == 4hr, etc
WatcherCount=14400
DAG="Collection.dag"
# replace the JOB node that creates the subdag with a bash script so i don't lose my mind
# relies on three files
# AssembliesExpected.txt is a simple txt file with a single assembly file name per line
File01="AssembliesCompleted.txt"
# AssembliesComplete.txt is the same though is only populated by assemblies already collected
File02="AssembliesExpected.txt"
# AssemplyPlanning.txt is a table of the expected VAR arguments for the dag
File03="AssemblyPlanning.txt"

# AssembliesExpected and AssemblyPlanning need to be the same length

# collect current completed jobs
shopt -s nullglob
for file in Assembly*.RData; do
  [[ -f $file && -s $file ]] && printf '%s\n' "$file"
done > AssembliesCompleted.txt

# use back substitution and wrap in parens so that the file name isn't printed
Completed=$(wc -l < "${File01}")
Expected=$(wc -l < "${File02}")

# learn how to automatically assign these based on the number of columns in the planning file...
PlanVal01=($(awk '{print $1}' "${File03}")) # ftp folder
PlanVal02=($(awk '{print $2}' "${File03}")) # persistent ID
PlanVal03=($(awk '{print $3}' "${File03}")) # PFAM training set

check01=${#PlanVal01[@]}

# both this script, and the post-script need to check for the existence of 
# log and rescue files from a previous iteration
for file in /NodeB/NodeBA/${DAG}; do
  if [ -f $file ]; then
    rm $file
  fi
done

if [[ ! ${Expected} -eq ${check01} ]]; then
  echo "${DateVal}::Planning file and expected reference file are not the same length..."
  exit 1
  # printf "${DateVal}::Planning file and expected reference file are not the same length...\n"
else
  echo "${DateVal}::Planning file and expected reference file appear to exist as expected..."
  # echo ${check01}
  # echo ${Expected}
  # if we have the files as expected, we need to start building the dag
  # start with the watcher service
  cp Watcher/Chronos.txt "${DAG}"
  # add a new line for fun
  printf "\n" >> "${DAG}"
  # edit the watcher's time limit based on a variable coded into the script
  sed -i "s/PLACEHOLDER/${WatcherCount}/g" "${DAG}"
  # now we just loop through ExpectedAssemblies, and if the value isn't present
  # in completed assemblies, we add the associated lines
  CurrentIterator=1
  while IFS= read -r line; do
  # only write out lines that are needed
    if ! grep -Fxq "$line" "$File01"; then
      printf 'JOB B%d NodeB/NodeBA/Collection.sub\n' "${CurrentIterator}" >> "${DAG}"
      printf 'VARS B%d Address="%s" PersistentID="%d" PFAM="%s"\n' ${CurrentIterator} ${PlanVal01[((${CurrentIterator} - 1))]} ${PlanVal02[(($CurrentIterator - 1))]} ${PlanVal03[((${CurrentIterator} - 1))]} >> "${DAG}"
    fi
    ((CurrentIterator++))
  done < "${File02}"
  
  # append the service's other line
  printf "\nABORT-DAG-ON WATCHER 2 RETURN 1\n" >> "${DAG}"
  mv "${DAG}" NodeB/NodeBA/"${DAG}"
  
fi


