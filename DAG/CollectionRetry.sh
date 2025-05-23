#! /bin/bash

dateval=$(date)

shopt -s nullglob
other_vals01=$(tail -n 1 "TrackerFiles/VersionStart.txt")
other_vals01=$(echo "${other_vals01}" | cut -d " " -f1)
other_vals02=$(tail -n 1 "TrackerFiles/BStart.txt")
LIM=10
# post collection DAG
# nuke the associated DAG files and then ...
# AssembliesExpected.txt is a simple txt file with a single assembly file name per line
File01="v${other_vals01}_assemblies_completed.txt"
# AssembliesComplete.txt is the same though is only populated by assemblies already collected
File02="v${other_vals01}_assemblies_expected.txt"
# AssemplyPlanning.txt is a table of the expected VAR arguments for the dag
File03="v${other_vals01}_assemblies_planned.txt"
# FTP_Key for future pulls
File04="FTP_Key.txt"

# use redirection and wrap in parens so that the file name isn't printed
Completed=$(wc -l < "${File01}")
Expected=$(wc -l < "${File02}")

# two temp awk programs to access:
tmp01=$(mktemp)
tmp02=$(mktemp)
# temporary placeholders:
tmp03=$(mktemp)
tmp04=$(mktemp)

echo '
BEGIN { FS="" }
(NR==FNR) {  # file1, index by lineno and string
  ll1[FNR]=$0; ss1[$0]=FNR; nl1=FNR;
}
(NR!=FNR) {  # file2
  if ($0 in ss1) { delete ll1[ss1[$0]]; delete ss1[$0]; }
}
END {
  for (ll=1; ll<=nl1; ll++) if (ll in ll1) print ll1[ll]
}
' > ${tmp01}
# awk -f <program> <expected> <existing> > output

echo '
# when the filename is equivalent to the first trailing argument
FILENAME == ARGV[1] {
  exclude[$1];
  next
}
# when the filename is equivalent to the second trailing argument
FILENAME == ARGV[2] && !($2 in exclude) {
  print $1 " " $2
}
' > ${tmp02}
# awk -f <program> <absent> <planning> > <output>

# this needs to happen at the top most level
# the node inherits the exit condition of the post script
# if I've hit the limit and there are addresses remaining to be queried, nuke them
# from the list so that they get called again
if [ ${Completed} -eq ${Expected} ]; then
  # print an update to the logfile before exiting
  printf "  NodeB completed %d of %d assemblies on attempt %d [${dateval}]\n" ${Completed} ${Expected} ${other_vals02} >> SummaryFiles/log.txt
  tar czvf assemblylists.tar.xz v*_assemblies_completed.txt
  rm TrackerFiles/BStart.txt
  rm TrackerFiles/BEnd.txt
  rm ${tmp01} ${tmp02} ${tmp03} ${tmp04}
  exit 0
else
  if [ ${LIM} -eq ${other_vals02} ]; then
    # step 1: find missing result files
    # awk -f <program> <expected> <existing> > output
    awk -f ${tmp01} ${File02} ${File01} > ${tmp03}
    # step 2: convert file name to assembly persistent id
    sed -E 's/^Assembly0*([0-9]+)\.RData$/\1/' ${tmp03} > ${tmp04}
    # step 3: remove lines from the planning file that represent assemblies that were missed after all attempts
    # awk -f <program> <absent> <planning> > <output>
    # we're only rewriting the FTP_Key here ... the planning files shouldn't need to be edited, at least for now?
    awk -f ${tmp02} ${tmp04} ${File03} > ${File04}
    # print an update to the logfile before exiting
    printf "  NodeB completed %d of %d assemblies on attempt %d [${dateval}]\n" ${Completed} ${Expected} ${other_vals02} >> SummaryFiles/log.txt
    tar czvf assemblylists.tar.xz v*_assemblies_completed.txt
    rm TrackerFiles/BStart.txt
    rm TrackerFiles/BEnd.txt
    rm ${tmp01} ${tmp02} ${tmp03} ${tmp04}
    exit 0
  fi
  rm ${tmp01} ${tmp02} ${tmp03} ${tmp04}
  exit 1
fi
