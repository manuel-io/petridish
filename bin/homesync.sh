#!/bin/bash

error="/dev/stderr"
exclude="repos movies mtp tmp videos"
exlist=""
destdir=""

[ -z $1 ] || [ ! -d $1 ] && {
  echo "No destination directory" > $error
  exit 1
}

cd $HOME
destdir=$1

for exfile in $exclude
do
  exlist="${exlist} --exclude ${exfile}"
done

for dir in `find ${HOME}/ -mindepth 1 -maxdepth 1 -type d -name '[a-z]*'`
do
  echo $dir

#  find $dir -type f -exec chmod a-x '{}' \;
#  find $dir -exec chmod go-rwx '{}' \;
#  find $dir -type f -exec chmod a-w '{}' \;

#  chown -R `id -un`:`id -gn` $dir

  rsync -rva --ignore-existing $exlist $dir $destdir
done
