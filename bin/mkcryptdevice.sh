#!/bin/bash
format="-c aes-xts-plain64 -h sha512 -s 512"
key=$(gnome-keyring-query get filesystem)

echo -n $key > /tmp/keyfile

sudo cryptsetup luksAddKey /dev/sdc1 keyfile
sudo cryptsetup luksAddKey /dev/sdc2 keyfile

shred -u /tmp/keyfile
