#! /bin/bash

dateval=$(date)
# 3600 seconds in an hour: 7200 == 2hr, 14400 == 4hr, etc
WatcherCount=14400
DAG="Collection.dag"
LIM=10
other_vals01=$(tail -n 1 "TrackerFiles/VersionStart.txt")
other_vals01=$(echo "${other_vals01}" | cut -d " " -f1)
# replace the JOB node that creates the subdag with a bash script so i don't lose my mind
# relies on three files
# AssembliesExpected.txt is a simple txt file with a single assembly file name per line
File01="v${other_vals01}_assemblies_completed.txt"
# AssembliesComplete.txt is the same though is only populated by assemblies already collected
File02="v${other_vals01}_assemblies_expected.txt"
# AssemplyPlanning.txt is a table of the expected VAR arguments for the dag
File03="v${other_vals01}_assemblies_planned.txt"
# File04=$(mktemp)

# AssembliesExpected and AssemblyPlanning need to be the same length

# collect current completed jobs
shopt -s nullglob
for file in Assembly*.RData; do
  [[ -f $file && -s $file ]] && printf '%s\n' "$file"
done > ${File01}

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
for file in NodeB/NodeBA/${DAG}*; do
  if [ -f $file ]; then
    rm $file
  fi
done

if [[ ! ${Expected} -eq ${check01} ]]; then
  echo "${dateval}::Planning file and expected reference file are not the same length..."
  exit 1
  # printf "${dateval}::Planning file and expected reference file are not the same length...\n"
else
  echo "${dateval}::Planning file and expected reference file appear to exist as expected..."
  # echo ${check01}
  # echo ${Expected}
  # if we have the files as expected, we need to start building the dag
  # start with the watcher service
  cp Watcher/Chronos.txt "${DAG}"
  # add a new line for fun
  printf "\n" >> "${DAG}"
  # edit the watcher's time limit based on a variable coded into the script
  sed -i "s/PLACEHOLDER/${WatcherCount}/g" "${DAG}"
  # we create a tempfile that has all the expected assemblies still to be produced
  # grep -vxf "${File01}" "${File02}" > "${File04}"
  IteratorA=1
  IteratorB=1
  while IFS= read -r line; do
  # only write out lines that are needed
  # if the the assembly is not already present in the completed txt file write it out to the DAG
  # if the assembly is already present, skip it and do not count
    if ! grep -Fxq "${line}" "${File01}"; then
      printf 'JOB B%d NodeB/NodeBA/Collection.sub\n' ${IteratorA} >> ${DAG}
      printf 'VARS B%d Address="%s" PersistentID="%d" PFAM="%s"\n' ${IteratorA} ${PlanVal01[((${IteratorB} - 1))]} ${PlanVal02[(($IteratorB - 1))]} ${PlanVal03[((${IteratorB} - 1))]} >> ${DAG}
      # a and b iterator on the addition
      ((IteratorA++))
      ((IteratorB++))
    else
      # only b iterates when we skip
      # ((IteratorA++))
      ((IteratorB++))
    fi
    if [ $IteratorA -gt $LIM ]; then
      break
    fi
  done < "${File02}"
  # rm "${File04}"
  # append the service's other line
  printf "\nABORT-DAG-ON WATCHER 2 RETURN 1\n" >> ${DAG}
  mv ${DAG} NodeB/NodeBA/${DAG}
fi

IteratorC=$((IteratorA - 1))
printf "    NodeBA DAG with %d jobs generated [${dateval}]\n" ${IteratorC} >> SummaryFiles/log.txt

if [ -e "TrackerFiles/BStart.txt" ]; then
  lineval=$(tail -n 1 "TrackerFiles/BStart.txt")
  iteration=$(echo $lineval | cut -d " " -f1)
  # totalcount=$(echo $lineval | cut -d ':' -f5)
  ((iteration++))
  printf "$iteration\n" >> TrackerFiles/BStart.txt
else
  iteration=1
  printf "$iteration\n" > TrackerFiles/BStart.txt
fi
