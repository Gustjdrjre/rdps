#!/bin/bash

#Please modify the following two entries before using. mount_point为挂载点，把“vv”改为自己的用户名即可。soft_link是桌面建立的一个快捷方式。
mount_point=/home/vv/tracking_list
soft_link=/home/vv/Desktop/tracking_list.ods

mount_from=192.168.1.249:/home/appsup/share

if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root." 1>&2
    exit 1
fi

echo "Caution!
Please make sure you have modified the script before you run it!
Enter 'y' to continue, any other key to quit:"
read confirm
if [ $confirm = "y" ]; then
    if [ "$1" = "remove" ]; then
        umount $mount_point
        rmdir $mount_point
        rm -f $soft_link
        sed -i "/`echo $mount_point | awk -F/ '{print $2"."$3"."$4}'`/d" /etc/fstab
        echo "Removed."
        exit 0
    fi
    
    if [ ! -d $mount_point ]; then
        echo "Making directory $mount_point..."
        mkdir $mount_point
    fi
    
    grep $mount_point /etc/mtab 2>&1 >/dev/null
    if [ $? = 0 ]; then
        echo "$mount_point already mounted."
    else
        echo "Mounting $mount_from to $mount_point..."
        mount $mount_from $mount_point
    fi
    
    grep $mount_point /etc/fstab 2>&1 >/dev/null
    if [ $? != 0 ]; then
        echo "Adding entry to fstab..."
        echo "$mount_from $mount_point nfs rw,addr=192.168.1.249 0 0" >> /etc/fstab
    fi
    
    if [ ! -f $soft_link ]; then
        echo "Creating soft link $soft_link..."
        ln -s $mount_point/tracking_list.ods $soft_link
    fi
    echo "Completed."
fi
