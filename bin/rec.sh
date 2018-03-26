#!/bin/bash
i=0

[ -z $1  ] &&
echo "Usage: rec.sh url" && exit

while true
do
  name=$(printf outout%0d $i)
  avconv -i $1 -qscale 1 -acodec libmp3lame -vcodec libx264 "${name}.avi"
  echo $i
  ((i++))
done
