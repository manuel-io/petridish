#!/bin/bash

# touchr [OPTION] -r REFERENCE DIRECTORY... MODIFICATION DIRECTORIES...

# The script changes modification- and access-time of files recursively 
# in a specified directory by comparing to one other
# like `touch -r /old/file /new/file` would do it.

# OPTIONS
# -v verbose
# -d debug

# EXAMPLES
# This is just a test to show which files will be modified.
# The -d flag implies verbose (-v).
#  $ touchr -dr /your/reference/directory /your/modification/directory

# If everything is fine.
#  $ touchr -vr /your/reference/directory /your/modification/directory 

function touchr_opts {
  while getopts ":r:vd" optname; do
    case $optname in
      "v") VISIBLE=true;;
      "r") REFERENCE=$OPTARG;;
      "d") DEBUG=true; VISIBLE=true;;
      ":") echo ":: No argument value for option $OPTARG"; exit;;
        *) echo ":: Unknown error while processing options"; exit;;
    esac
  done
  return $OPTIND
}

touchr_opts $@
minus=$?

if [ $VISIBLE ]; then echo ":: Your reference directory is $REFERENCE"; fi

for modification in ${@:$minus}; do
  if [ $VISIBLE ]; then echo ":: Your modification directory is $modification"; fi
  for file in `find $REFERENCE -type f`; do 
    if [ $VISIBLE ]; then echo "${file:${#REFERENCE}}"; fi
    if [ ! $DEBUG ]; then touch -r${file} ${modification}/${file:${#REFERENCE}}; fi
  done
done
