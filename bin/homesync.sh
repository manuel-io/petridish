#!/bin/bash

erro="/dev/stderr"
exclude="repos movies mtp tmp"
exlist=""
destdir=""

[ -z $1 ] || [ ! -d $1 ] && {
  echo "No destination directory" > $erro
  exit 1
}

destdir=$1

for exfile in $exclude
do
  exlist="${exlist} --exclude ${exfile}"
done

for dir in `find ${HOME}/ -mindepth 1 -maxdepth 1 -type d -name '[a-z]*'`
do
  echo $dir
  rsync -rva --ignore-existing $exlist $dir $destdir
done
