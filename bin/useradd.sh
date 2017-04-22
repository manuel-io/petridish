#!/bin/bash
SHELL=/usr/bin/zsh
ERROR=/dev/stderr
USER="username"
ID=1200

groupadd -g $ID $USER
useradd --uid $ID --gid $ID -s $SHELL -d /home/$USER $USER

lvcreate -L 10G -n $USER users
mkfs.ext4 /dev/mapper/users-$USER
mkdir /home/$USER
mount /dev/mapper/users-$USER /home/$USER/
chown -R $USER:$USER /home/$USER/

echo "Add to your /etc/fstab:" > $ERROR
echo "/dev/mapper/users-$USER /home/$USER ext4 defaults 0 2"

passwd $USER
#read

#userdel $USER
#groupdel $USER
#umount /home/$USER/
#lvremove -f users/$USER
#rmdir /home/$USER/
