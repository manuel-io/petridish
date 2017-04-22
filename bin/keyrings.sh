#!/bin/bash
backups="${HOME}/backups/keyrings"
mkdir -p $backups

[ -f "${HOME}/.uniqid" ] &&
  [ $(wc -c "${HOME}/.uniqid" | cut -d\  -f1) -ge 30 ] || {
    echo "First generate a uniq ID:" > /dev/stderr
    echo "Example: cat file | sha256sum | cut -b 1-64 > ${HOME}/.uniqid " > /dev/stderr
    exit 1
  }

for file in $(find $HOME -name '*.kdbx' -type f | head -n 1)
do
  filepath=$(realpath $file)
  filebase=$(basename $filepath .kdbx)
  filedir=$(dirname $filepath)
  fileout="${backups}/${filebase}-$(whoami)-$(date +%Y-%m-%d).kdbx.enc"

  [ -f "${fileout}" ] || {
    openssl enc -aes-256-cbc -pass "file:${HOME}/.uniqid" \
      -e -in "${filepath}" -out "${fileout}"
  }
done
