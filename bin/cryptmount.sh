#!/bin/bash

# Usage: cryptmount.sh [umount] <device>

# i.e. cryptmount.sh sda
#      cryptmount.sh umount sda

device="sdevice"
device_derived="/lib/cryptsetup/scripts/decrypt_derived"
null=/dev/null
error=/dev/stderr

function mount_extern {
  for i in {1..4}
  do
    full="${device}${i}"
    [ -b "/dev/${full}" ] && [ -r "/dev/${full}" ] && {
      $device_derived "${device}1" 2> $null \
        | cryptsetup luksOpen "/dev/${full}" "${full}"
      [ ! $? -eq 0 ] && cryptsetup luksOpen "/dev/${full}" "${full}"
      echo "mount: ${full}" > $error
      mkdir -p "/mnt/${full}"
      mount "/dev/mapper/${full}" "/mnt/${full}"
    }
  done
}

function umount_extern {
  for i in {1..4}
  do
    full="${device}${i}"
    echo "umount: ${full}" > $error
    umount "/mnt/${full}"
    cryptsetup luksClose "${full}"
  done
}

[ -z $1 ] && {
  echo "Usage: cryptmount.sh [umount] <device>"
  exit
}

[ $1 == "umount" ] && {
  device=$2
  umount_extern
} || {
  device=$1
  mount_extern
}
