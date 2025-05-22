#! /bin/bash


args01=$1
args02=$2
args03=$3

tmp01=$(mktemp)
tmp02=$(mktemp)

# explicit file name setting with -v
echo '
FILENAME == absent {
  exclude[$1];
  next
}
FILENAME == planning && !($2 in exclude) {
  print
}
' > ${tmp01}

# implicit filename accessing with ARGV syntax
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

# awk -v absent="${args01}" \
#   -v planning="${args02}" \
#   -f ${tmp01} ${args01} ${args02} > ${args03}
  
awk -f ${tmp02} ${args01} ${args02} > ${args03}

rm ${tmp01}
rm ${tmp02}
  
  