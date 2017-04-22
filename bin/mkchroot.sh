#!/bin/bash
mount /dev/mapper/system-root /mnt
mount /dev/mapper/system-home /mnt/home
mount /dev/sda1 /mnt/boot
mount -o rbind /dev /mnt/dev
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o rbind /run/lvm /mnt/run/lvm
mount -o rbind /run/lock/lvm /mnt/run/lock/lvm
cp /etc/resolv.conf /mnt/etc/resolv.conf
cp /etc/hosts /mnt/etc/hosts
