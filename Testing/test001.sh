#! /bin/bash

args01=$1
args02=$2
args03=$3
# args04=$4
tmp01=$(mktemp)

# return lines not present in file b that are present in file a
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

# awk -f <file> <expected> <existing> > <output>
awk -f ${tmp01} ${args01} ${args02} > ${args03}

rm ${tmp01}
