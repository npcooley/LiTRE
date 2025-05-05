#! /bin/bash

# pre-flight, plan the Run DAG and set up its submission 

# capture the current version of the dag and a set a few things
dateval=$(date)
# 3600 seconds in an hour: 7200 == 2hr, 14400 == 4hr, etc
WatcherCount=14400
DAG="Flight.dag"
LIM=100
other_vals01=$(tail -n 1 "TrackerFiles/VersionStart.txt") # this is the current version
other_vals01=$(echo "${other_vals01}" | cut -d " " -f1)

# relies on three files
# AssembliesExpected.txt is a simple txt file with a single assembly file name per line
File01="v${other_vals01}_comparisons_completed.txt"
# AssembliesComplete.txt is the same though is only populated by assemblies already collected
File02="v${other_vals01}_comparisons_expected.txt"
# AssemplyPlanning.txt is a table of the expected VAR arguments for the dag
File03="v${other_vals01}_comparisons_planned.txt"

# this task occurs at the post DAG script, not here...
# collect current completed jobs
# shopt -s nullglob
# for file in Pairwise*.txt.gz; do
#   if [[ -f $file && -s $file ]]; then
#     printf '%s\n' "$file"
#   fi
# done > ${File01}

# both this script, and the post-script need to check for the existence of 
# log and rescue files from a previous iteration
for file in NodeD/NodeDA/${DAG}*; do
  if [ -f $file ]; then
    rm $file
  fi
done

# use back substitution and wrap in parens so that the file name isn't printed
Completed=$(wc -l < "${File01}")
Expected=$(wc -l < "${File02}")


# learn how to automatically assign these based on the number of columns in the planning file...
PlanVal01=($(awk '{print $1}' "${File03}")) # which of the SORTED comparisons files to reference ... i do need this
PlanVal02=($(awk '{print $2}' "${File03}")) # m2 count always the most recent version of completed assemblies
PlanVal03=($(awk '{print $3}' "${File03}")) # m3 count always the loop version of completed assemblies, i.e. the changing one
PlanVal04=($(awk '{print $4}' "${File03}")) # persistent ID

check01=${#PlanVal01[@]}

# ls -v version sorts on numbers embedded within a string
version_opts=($(ls v*_assemblies_completed.txt | sort --version-sort)) # put the names of the text files into an array
# create an array of the expected comparison results
exp_array=($(cat "$File02"))

assembly_list_static=($(cat ${version_opts[@]}))
assembly_list_dynamic=($(cat ${version_opts[0]}))


# start with the watcher service
cp Watcher/Chronos.txt ${DAG}
# edit the watcher's time limit based on a variable coded into the script
sed -i "s/PLACEHOLDER/${WatcherCount}/g" ${DAG}
IteratorA=1
IteratorB=1
IteratorC=0 # the version opts iterator for array access
IteratorD=1

# loop over the expected comparisons file, while comparing with the completed comparisons
while IFS= read -r line; do
# only write out lines that are needed
# if the the assembly is not already present in the completed txt file write it out to the DAG
# if the assembly is already present, skip it and do not count
  if ! grep -Fxq "$line" "$File01"; then
    # if the dynamic access key isn't the current one, change it
    if [ ! ${PlanVal01[$IteratorC]} -eq $IteratorD ]; then
      # this needs to be slightly more convoluted to be robust, but in the case that everything is sorted as i expect,
      # this would work fine
      IteratorC=$((${PlanVal01[${IteratorC}]} - 1))
      IteratorD=$(($IteratorC + 1))
      assembly_list_dynamic=($(cat ${version_opts[${PlanVal01[$IteratorC]}]}))
    fi
    printf 'JOB D%d NodeD/NodeDA/Flight.sub\n' ${IteratorA} >> ${DAG}
    printf 'VARS D%d ' ${IteratorA} >> ${DAG}
    IteratorE=$((${IteratorB} - 1))
    IteratorF=${PlanVal02[${IteratorE}]}
    IteratorG=$((${IteratorF} - 1))
    IteratorH=${PlanVal03[$IteratorE]}
    IteratorI=$(($IteratorH - 1))
    printf 'Partner1="%s" ' ${assembly_list_static[$IteratorG]} >> ${DAG}
    printf 'Partner2="%s" ' ${assembly_list_dynamic[$IteratorI]} >> ${DAG}
    printf 'PersistentID="%d"\n' ${PlanVal04[${IteratorE}]} >> ${DAG}
    # a and b iterator on the addition
    ((IteratorA++))
    ((IteratorB++))
  else
    # only b iterates when we skip
    ((IteratorB++))
  fi
  if [ $IteratorA -gt $LIM ]; then
    break
  fi
done < "${File02}" # feed in the expected comparisons file

# append the service's other line
printf "\nABORT-DAG-ON WATCHER 2 RETURN 1\n" >> ${DAG}
mv ${DAG} NodeD/NodeDA/${DAG}

IteratorJ=$((IteratorA - 1))
printf "    NodeDA DAG with %d jobs planned [${dateval}]\n" $IteratorJ >> SummaryFiles/log.txt

if [ -e "TrackerFiles/DStart.txt" ]; then
  lineval=$(tail -n 1 "TrackerFiles/DStart.txt")
  iteration=$(echo $lineval | cut -d " " -f1)
  # totalcount=$(echo $lineval | cut -d ':' -f5)
  ((iteration++))
  printf "%d\n" ${iteration} >> TrackerFiles/DStart.txt
else
  iteration=1
  printf "%d\n" ${iteration} > TrackerFiles/DStart.txt
fi




