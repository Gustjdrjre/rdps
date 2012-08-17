#!/bin/bash

#This script is written by Victor Zhou(victor.zhou@rdps-china.com) to make RDPS daily imail server check more convenient and less time consuming.
#The main job this script does is helping you type all the ssh commands and open the maddog system reports webpage.
#Copy the server list from email to the file which you specify your 'list_file' as, then run this script.
#When the script is running, you can input "x" or "X" to quit. The differences between "x" and "X" are that when you quit with "x", you can skip servers you already checked this time and begin with the next server next time you run this script, but when you quit with "X", if you run this script again, the script'll prompt you to ssh to each server from the beginning.

#When you use this script the first time, please change the following three entries to make the script suitable for you.

user=vzhou
work_dir=/home/vv/Desktop
list_file=$work_dir/imail_server_check_list

if [ ! -f $list_file ]; then
	echo "Server list file does not exist!"
	exit
fi

listdate=`date -r $list_file | awk '{print $1$2$3}'`
today=`date | awk '{print $1$2$3}'`
if [ $listdate != $today ]; then
	echo "Please renew the server list file"
	exit
fi

trap "" SIGINT

declare -a list
declare -a pointer_date_check
list=(`cat $list_file`)
total=${#list[@]}
count=`expr $total - 1`

pointer=0
if [ -f $work_dir/.pointer ]; then
	pointer_date_check=(`cat $work_dir/.pointer`)
	if [ ${pointer_date_check[0]} = $today ]; then
		pointer=${pointer_date_check[1]}
	fi
	rm -f $work_dir/.pointer
fi

while [ $pointer -le $count ]
do
	position=`expr $pointer + 1`
	echo -------- $position/$total --------
	echo ssh $user@${list[$pointer]}
	ssh $user@${list[$pointer]}

	firefox http://172.18.240.126/snms/sys_reports/sys.cgi?host=${list[$pointer]}

	pointer=`expr $pointer + 1`

	echo "Press any key to continue, x to break, or X to exit"
	read action
	if [[ $action = x ]]; then
		date | awk '{print $1$2$3}' > $work_dir/.pointer
		echo $pointer >> $work_dir/.pointer 
		exit
	fi

	if [[ $action = X ]]; then
		exit
	fi

done

