#!/bin/bash

user=vzhou
work_dir=/home/vv/Script
list_file=$work_dir/.sr_list
if [ -f $list_file ]; then
rm -r $list_file
fi
echo "eastsrncl01 eastsrncl02 eastsrwww01 eastsrwww02 eastsrwww03 eastsrwww04" > $list_file

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

