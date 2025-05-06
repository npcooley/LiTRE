#! /bin/bash

# only a single input is allowed
# given the input take in the upper level keys and loop through them
# extract the file type for context
# loop through the second level keys which are assumed to be variables
# and assign the values for the key to the value for the variable in the designated file
# value replacement is done for the entire line 

# some of our assumptions:
# values to be replaced and edited are always of length 1
# values are (so far) always integer limits

# filename=$(basename -- "$fullfile")
# extension="${filename##*.}"
# filename="${filename%.*}"

# given this:
# cat DAG/prodvals.json 
# {
#     "Manager.dag": {
#         "RETRY B": [
#             10
#         ],
#         "RETRY D": [
#             250
#         ]
#     },
#     "PlanCollection.R": {
#         "LIM": [
#             5000
#         ]
#     },
#     "Plan.R": {
#         "LIM": [
#             500000
#         ]
#     }
# }

# $ jq 'keys' DAG/prodvals.json 
# [
#   "Manager.dag",
#   "Plan.R",
#   "PlanCollection.R"
# ]

# $ jq '."Manager.dag" | keys' DAG/prodvals.json 
# [
#   "RETRY B",
#   "RETRY D"
# ]

# only allow a single argument
if [ "$#" -ne 1 ]; then
  echo "Script accepts only a single argument."
  exit 1
fi

file01="$1"

# string='"'"$folder"'"'
# variable substitution
files02=$(jq -r 'keys[]' "${file01}")
# don't quote this first array
IFS=$'\n'
for vals01 in ${files02[@]}; do
  string01='"'"$vals01"'"'
  filename=$(basename $vals01)
  fileext="${filename##*.}"
  # echo "$fileext"
  # echo "${string01}"
  sub_vals=$(jq -r ' .'"${string01}"' | keys[]' ${file01})
  for vals02 in ${sub_vals[@]}; do
    string02='"'"$vals02"'"'
    # echo ' .'"${string01}"'.'"${string02}"'[]'
    replacement=$(jq -r ' .'"${string01}"'.'"${string02}"'[]' ${file01})
    # string01 == file to replace within
    # string02 == variable to replace
    # string03  == variable with the quotes dropped
    # find the lines, take only the first occurence, remove grep's extraneous outputs
    lineval=$(grep -n -m 1 "$vals02" "$vals01" | cut -d: -f1)
    # in .dag files variables will only appear once
    # in .R files variables will appear several times, the first should be their initial assignment
    
    if [[ "$fileext" == "dag" ]]; then
    # giving the -i '' and -e flags explicitly seems to matter here?
       sed -i '' -e "${lineval}s/${vals02}.*/${vals02} ${replacement}/" ${vals01}
    elif [[ "$fileext" == "R" ]]; then
       sed -i '' -e "${lineval}s/${vals02}.*/${vals02} <- ${replacement}/" ${vals01}
    elif [[ "$fileext" == "sh" ]]; then
      sed -i '' -e "${lineval}s/${vals02}.*/${vals02}=${replacement}/" ${vals01}
    else
       echo "file extension is not recognized"
       exit 1
    fi
    
    echo "$vals02 to be appended with $replacement on line $lineval in $vals01"
    # echo "$vals02"
  done
  # echo "$vals01"
done



