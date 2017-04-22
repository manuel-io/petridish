#!/bin/bash

# dd if=/dev/urandom of=disk.img bs=1024 count=1048576
# losetup /dev/loop0 disk.img

user = manuel
device = /dev/sda
puts "Hello"
exit
# Stage 1
# sfdisk disk.img << EOF
# 2048,10GiB,83,*
# ,64GiB,8e
# ,,8e
# EOF

stage 2 do
  # Stage 2
  `cryptsetup luksFormat -c xts-plain64 -h sha512 -s 512 "${device}2"`
cryptsetup luksFormat -c xts-plain64 -h sha512 -s 512 "${device}3"
cryptsetup luksOpen "${device}2" linux
cryptsetup luksOpen "${device}3" users
/lib/cryptsetup/scripts/decrypt_derived linux ~/fskey
cryptsetup luksAddKey "${device}3" ~/fskey
end

# Stage 3
pvcreate /dev/mapper/linux
pvcreate /dev/mapper/users
vgcreate linux /dev/mapper/linux
vgcreate users /dev/mapper/users
lvcreate -L 4G -n swap linux
lvcreate -L 10G -n home linux
lvcreate -l 100%FREE -n root linux
lvcreate -L 100G -n "${user}" users

mkswap -L swap /dev/mapper/linux-swap
mkfs.ext4 -b 4096 -L boot "${device}1"
mkfs.ext4 -b 4096 -L root /dev/mapper/linux-root
mkfs.ext4 -b 4096 -L home /dev/mapper/linux-home
mkfs.ext4 -b 4096 -L "${user}" "/dev/mapper/users-${user}"

# Stage 4
swapoff -a
shred -u ~/fskey
# losetup -d /dev/loop0

mount /dev/mapper/linux-root /mnt
mount "${device}1" /mnt/boot
mount /dev/mapper/linux-home /mnt/home
mount "/dev/mapper/users-${user}" "/mnt/home/${user}"
mount -o rbind /dev /mnt/dev
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o rbind /run/lvm /mnt/run/lvm
mount -o rbind /run/lock/lvm /mnt/run/lock/lvm

cp /etc/resolv.conf /mnt/etc/resolv.conf

# In das verschlüsselte System wechseln
# chroot /mnt /bin/bash 

echo "dm-crypt" >> /etc/modules
update-initramfs -u -k all
GRUB_CMDLINE_LINUX_DEFAULT="kopt=root=/dev/mapper/vgubuntu-root"
update-grub
