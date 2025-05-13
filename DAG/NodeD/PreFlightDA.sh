#! /bin/bash

# pre-flight, plan the Run DAG and set up its submission 

# capture the current version of the dag and a set a few things
dateval=$(date)
# 3600 seconds in an hour: 7200 == 2hr, 14400 == 4hr, etc
WatcherCount=14400
DAG="Flight.dag"
LIM=50000
other_vals01=$(tail -n 1 "TrackerFiles/VersionStart.txt") # this is the current version
other_vals01=$(echo "${other_vals01}" | cut -d " " -f1)

expected="v${other_vals01}_comparisons_expected.txt"
# existing == vNN_comparisons_completed.txt
existing="v${other_vals01}_comparisons_completed.txt"
# planning == vNN_comparisons_planned.txt
# a planning map containing 4 columns
# 1 == integer key for the file that column 3 references
# 2 == integer key for the line in the most recent assemblies file to grab
# 3 == integer key for the line in the key'd file from column 1 to grab
# 4 == integer reference for the pairwise result identifier
planning="v${other_vals01}_comparisons_planned.txt"

# relies on three files
# AssembliesExpected.txt is a simple txt file with a single assembly file name per line
File01="v${other_vals01}_comparisons_completed.txt"
# AssembliesComplete.txt is the same though is only populated by assemblies already collected
File02="v${other_vals01}_comparisons_expected.txt"
# AssemplyPlanning.txt is a table of the expected VAR arguments for the dag
File03="v${other_vals01}_comparisons_planned.txt"

# both this script, and the post-script need to check for the existence of 
# log and rescue files from a previous iteration
for file in NodeD/NodeDA/${DAG}*; do
  if [ -f $file ]; then
    rm $file
  fi
done

# use back substitution and wrap in parens so that the file name isn't printed
Completed=$(wc -l < "${existing}")
Expected=$(wc -l < "${expected}")


# temp file for the first awk program
tmp01=$(mktemp)
# see SO question and answers:
# https://stackoverflow.com/questions/18204904/fast-way-of-finding-lines-in-one-file-that-are-not-in-another
echo 'BEGIN { FS="" }
(NR==FNR) {  # file1, index by lineno and string
  ll1[FNR]=$0; ss1[$0]=FNR; nl1=FNR;
}
(NR!=FNR) {  # file2
  if ($0 in ss1) { delete ll1[ss1[$0]]; delete ss1[$0]; }
}
END {
  for (ll=1; ll<=nl1; ll++) if (ll in ll1) print ll1[ll]
}' > ${tmp01}
# cat ${tmp01}
# temp file for the first intermediate result, i.e. all expected files that don't yet exist
tmp02=$(mktemp)
# temp file for the second intermediate result, the subset planning file that contains all the integer references
# that are necessary to build the new DAG
tmp03=$(mktemp)
# temp file to serve as the base name for split planning files
tmp04=$(mktemp)
# temp files for the second awk program -- two versions ...
# awk doesn't like having the same file or filename be used as different variables
# which is ... a case that is unavoidable due to how i set up other parts of this, for better or worse
# so two versions, one that takes in a single assembly text file
# and another that takes in two assembly text files
tmp05=$(mktemp)
echo 'FILENAME==filea { a[FNR]=$0; next }
FILENAME==fileb { b[FNR]=$0; next }
FILENAME==filec { c[FNR]=$0; next }
FILENAME==filed { print "JOB " $4 " NodeD/NodeDA/Flight.sub\n" "VARS " $4 " Partner1=\""a[$2]"\"", "Partner2=\""b[$3]"\"", "PersistentID=\""$4"\"" }' > ${tmp05}
# cat ${tmp05}
tmp06=$(mktemp)
echo 'FILENAME==filea { a[FNR]=$0; next }
FILENAME==fileb { b[FNR]=$0; next }
FILENAME==filec { print "JOB " $4 " NodeD/NodeDA/Flight.sub\n" "VARS " $4 " Partner1=\""a[$2]"\"", "Partner2=\""a[$3]"\"", "PersistentID=\""$4"\"" }' > ${tmp06}
# cat ${tmp06}

# ls -v version sorts on numbers embedded within a string, but doesn't seem to respect that order when adding to an array?
assembly_lists=($(ls v*_assemblies_completed.txt | sort --version-sort)) # put the names of the text files into an array
final_index=$((${#assembly_lists[@]} - 1))
# echo $final_index
# echo ${assembly_lists[${final_index}]}
assemblies_a=${assembly_lists[${final_index}]}

# start with the watcher service
cp Watcher/Chronos.txt ${DAG}
# edit the watcher's time limit based on a variable coded into the script
sed -i '' -e "s/PLACEHOLDER/${WatcherCount}/g" ${DAG}

# works as of bash 4.2, check the login node for bash version...
# assemblies_a=${assembly_lists[-1]}
# val1=${assembly_lists[-1]}
# echo ${val1}

# returns the result file names that haven't been accounted for yet
awk -f ${tmp01} ${expected} ${existing} > ${tmp02}

current_lines=$(wc -l < ${tmp02})

# truncate to 
if [ ${current_lines} -gt 50000 ]; then
  sed -i '' -e '50001,$ d' ${tmp02}
fi

# remove the prepended identifier
sed -i '' -e 's/^Pairwise0*//' ${tmp02}
# sed -i '' -e 's/^Assembly0*//' ${tmp02}

# remove .txt.gz
sed -i '' -e 's/\.[^.]*\.[^.]*$//' ${tmp02}

# remove .RData
# sed -i '' -e 's/\.[^.]*$//' ${tmp02}

# assemblies == integer in the second column, comparisons in the fourth
awk 'NR==FNR {keys[$1]; next} ($4 in keys)' ${tmp02} ${planning} > ${tmp03}
# awk 'NR==FNR {keys[$1]; next} ($2 in keys)' ${tmp02} ${planning} > ${result}

# head ${tmp03}

# split tmp03 -- the planning file lines that are relevant
awk -v base="${tmp04}" '{ key = sprintf("%04d", $1); print > (base "_" key) }' ${tmp03}
# echo ${tmp04}

for file in ${tmp04}_*; do
  # this is where the real funny business begins,
  # i don't know if i can *assume* that the integer pins these are named after mean anything,
  # so i need to grab the unique value of the first column, and use that to set the array that i'll be using
  # to do my stuff...
  # the file exists, is a regular file, and is greater than size zero
  if [ -f "$file" ]; then
    # echo "here!"
    # get the unique values in the first column
    # u1=$(awk '{print $1}' | sort -u)
    # but that's not necessary, i've already sorted it by the unique key
    # i just need to read the first value of the first column
    u1=$(awk 'NR==1 { print $1 }' "$file")
    # offset for array access, the array is sorted and the integer is keyed to that sort
    u1=$((u1 - 1))
    assemblies_b=${assembly_lists[${u1}]}
    if [ ${assemblies_a} == ${assemblies_b} ]; then
      awk -v filea="${assemblies_a}" \
        -v fileb="${expected}" \
        -v filec="${file}" \
        -f "${tmp06}" "${assemblies_a}" "${expected}" "${file}" >> ${DAG}
    else
      awk -v filea="${assemblies_a}" \
        -v fileb="${assemblies_b}" \
        -v filec="${expected}" \
        -v filed="${file}" \
        -f "${tmp05}" "${assemblies_a}" "${assemblies_b}" "${expected}" "${file}" >> ${DAG}
    fi
  fi
done

rm ${tmp01}
rm ${tmp02}
rm ${tmp03}
rm ${tmp04}*
rm ${tmp05}
rm ${tmp06}

# append the service's other line
printf "\nABORT-DAG-ON WATCHER 2 RETURN 1\n" >> ${DAG}
mv ${DAG} NodeD/NodeDA/${DAG}

submitted_lines=$(wc -l < ${tmp02})

printf "    NodeDA DAG with %d jobs planned [${dateval}]\n" ${submitted_lines} >> SummaryFiles/log.txt

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




