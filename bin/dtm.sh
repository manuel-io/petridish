#!/bin/bash

# $ tcpdump -i eth0 -A | grep mp4
# ...
# #EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1596000,RESOLUTION=960x540,CODECS="avc1.77.30,mp4a.40.2"
# http://adaptiv.wdr.de/i/medstdp/ww/fsk0/49/490051/,490051_5101127,490051_5101126,490051_5101125,490051_5101128,.mp4.csmil/index_2_av.m3u8?null=
# ...
# $ bash dtm.sh http://adaptiv.wdr.de/i ...

URL=$1
[ -z $URL ] && {
  echo "No playlist(url) given."
  exit 1
}

PLAYLIST=$HOME/playlist.m3a
TMP=$HOME/tmp
NUMMBER=1
FILE=$HOME/dtmrace.mp4

[ -a $FILE ] && {
  echo "Output file ${FILE} exists."
  exit 1
}

curl -o $PLAYLIST $URL
mkdir -p $TMP || exit 1

echo "Create ${TMP}."
echo "Create ${PLAYLIST}."

cat $PLAYLIST | grep '^http' | while read line
do
  NAME=$(printf vdo%03d.mp4 $NUMMBER)  
  NUMMBER=$(expr $NUMMBER + 1)
  [ -f $TMP/$NAME ] || curl -o $TMP/$NAME $line
done

cat $TMP/*.mp4 > $FILE
rm -rf $TMP
rm -f $PLAYLIST
echo "Delete ${TMP}."
echo "Delete ${PLAYLIST}"
echo "The End."
exit 0
