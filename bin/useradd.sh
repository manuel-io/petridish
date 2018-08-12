#!/bin/bash

SHELL=/usr/bin/zsh
ERROR=/dev/stderr
USER="worker"
ID=1300

mkdir /home/$USER
groupadd -g $ID $USER
useradd --uid $ID --gid $ID -s $SHELL -d /home/$USER $USER

lvcreate -l 100%FREE -n $USER users
mkfs.ext4 /dev/mapper/users-$USER
mount /dev/mapper/users-$USER /home/$USER/
chown -R $USER:$USER /home/$USER/

echo "Add to your /etc/fstab:" > $ERROR
echo "/dev/mapper/users-$USER /home/$USER ext4 defaults 0 2" > $ERROR

passwd $USER

# userdel $USER
# groupdel $USER
# umount /home/$USER/
# lvremove -f users/$USER
# rmdir /home/$USER/
