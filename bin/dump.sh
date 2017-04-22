#!/bin/bash

# The MIT License (MIT)

# Copyright (c) 2015 <m.a.n.u.e.l@posteo.net>

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# sudo apt-get install lsdvd mplayer mencoder normalize-audio
# vorbis-tools gpac mkvtoolnix mkvtoolnix-gui 

# EXAMPLES:
# bash dump.sh -vi -d /dev/dvd -t 01 -a 10 -l en -o reservoir-dogs.avi
# bash dump.sh -vm -d /dev/dvd -a 8 -l de -o pulp-fiction.avi
# bash dump.sh -vi -a 6 -l de \
#   -f matrix-revolutions.vob \
#   -s matrix-revolutions-small.avi
#   -o matrix-revolutions.avi

error=/dev/stderr
null=/dev/null
visible=false
debug=false
lang="de"
device="/dev/sr0"
file="file.vob"
small="small.avi"
outfile="out.avi"
aid=129
bitrate=946
#bitrate=1024
#bitrate=658
audiorate=128
volume=6
track='0'
interactive=false
makefile=false
subid="-nosub"
#subid="-sid 1"
#subid="-slang de -sid 1"

while getopts ":l:d:t:b:a:o:f:s:vim" optname
do
  case $optname in
    "i") interactive=true;;
    "v") debug=true; visible=true;;
    "m") makefile=true; interactive=true;;
    "l") lang=$OPTARG;;
    "d") device=$OPTARG;;
    "t") track=$OPTARG;;
    "b") bitrate=$OPTARG;;
    "a") volume=$OPTARG;;
    "o") outfile=$OPTARG;;
    "f") file=$OPTARG;;
    "s") small=$OPTARG;;
    ":") echo "No argument value for option ${OPTARG}" > $error; exit;;
      *) echo "Unknown error while processing options" > $error; exit;;
  esac
done

$makefile && {
  $visible && echo "Make empty files"
  touch $file
  touch $small
  touch $outfile
}

[ -b $device ] && [ $track -eq '0' ] && {
  track=$(lsdvd $device | sed -n 's/Longest track: //p')
}

$visible && {
  echo "File: ${file}"
  echo "Device: ${device}"
  echo "Track: ${track}"
  echo "Bitrate: ${bitrate}"
  echo "Language: ${lang}"
  echo "Volume: ${volume}"
  echo "Output: ${outfile}"
}

$interactive && [ -f $file ] && {
  read -p "Streamdump exists. Continue? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || {
    $visible && echo "exit"
    exit
  }
}

[ -f $file ] || {
  mplayer "dvd://${track}" \
    -dvd-device "${device}" -v \
    -dumpstream -dumpfile $file
}

$interactive && [ -f $small ] && {
  read -p "Preview file exists. Continue? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || {
    $visible && echo "exit"
    exit
  }
}

[ -f $small ] || {
  mencoder $file \
    $subid \
    -aid $aid \
    -ovc xvid \
    -xvidencopts "bvhq=1:chroma_opt:quant_type=mpeg:bitrate=${bitrate}" \
    -oac mp3lame \
    -lameopts "br=${audiorate}:cbr:vol=${volume}" \
    -force-avi-aspect 1.777777 \
    -ss 600 \
    -endpos 60 \
    -of avi \
    -o $small
}

$interactive && [ -f $outfile ] && {
  read -p "Output file exists. Continue? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || {
    $visible && echo "exit"
    exit
  }
}

[ -f $outfile ] || {
  mencoder $file \
    $subid \
    -aid $aid \
    -ovc xvid \
    -xvidencopts "bvhq=1:chroma_opt:quant_type=mpeg:bitrate=${bitrate}" \
    -oac mp3lame \
    -lameopts "br=${audiorate}:cbr:vol=${volume}" \
    -force-avi-aspect 1.777777 \
    -of avi \
    -o $outfile
}
