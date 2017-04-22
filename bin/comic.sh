#!/bin/bash

# Split Video
# avconv -i awo-2016-08-11.mp4 -r 25 output%04d.png

# Comic Style
for file in `find . -name 'output*.png' -type f | sort`
do
  name=$(basename $file .png)
  [ -f "filter-${name}.png" ] || {
    cartoon.sh -p 60 -e 4 -n 6 "${name}.png" "filter-${name}.png"
  }
done

# Merge Video
#avconv -framerate 25 -f image2 -i filter-output%04d.png -b 65536k out.avi
