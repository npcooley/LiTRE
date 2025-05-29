#! /bin/bash

# create manageable example files from files present in the .ignoredir directory
# grab the *last* 25 lines

shopt -s nullglob

iterate=1
for file in ./.ignoredir/*; do
  if [[ -s $file ]]; then
    if [[ $file == *.gz ]]; then
      tmp01=$(mktemp)
      gunzip -kc $file > $tmp01
      tail -n 50 $tmp01 > example_file_${iterate}.txt
      rm $tmp01
    else
      tail -n 50 $file > example_file_${iterate}.txt
    fi
    ((iterate++))
  fi
done

