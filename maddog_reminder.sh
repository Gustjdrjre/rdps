#!/bin/bash

#maddog颜色代码
#        红色    橙色    黄色    紫色    蓝色
#亮     FF0000  FFB329  FFFF00  B23AEE  63B8FF
#暗     aa0000  ce8f23  c9c900  6b238e  4785b7

sound="./mac/New_Mail.wav"
page="./webpage"
alarm="./alarm"
id="./id"
count_times=3
count=1
echo "Please input your username:"
read user
echo "Please input your password:"
stty_orig=`stty -g`
stty -echo
read password
stty $stty_orig

if [ -f $alarm ]; then
	rm -f $alarm
fi
if [ -f $id ]; then
	rm -f $id
fi
touch $id


{
while true; do
	
	if [ -f $page ]; then
		rm -f $page
	fi
	#Get the event console webpage and save it into a file(HTML).
	wget --user=$user --password=$password --no-check-certificate -O $page https://maddog.corp.cox.com/snms-http/event.fcgi > /dev/null 2>&1
	if [ $? = 1 ]; then
		mplayer $sound
		sleep 2
		mplayer $sound
		sleep 2
		mplayer $sound
		sleep 2
		mplayer $sound
		sleep 2
		mplayer $sound
		sleep 2
		mplayer $sound
		sleep 2
	fi
	#Format the silly html file.
	sed -i '/TD>$/N;s/\n//' $page
	
	#Check if there are new alarms that rdps needs to take care of.
	if [ -n "`cat $page | egrep -i "FF0000|FFB329|FFFF00|B23AEE|63B8FF" | egrep -i "db|dirm|ora|rac|eastsr|activecharge|dukeac|eastptixl0[12]"`" ] || [ -n "`cat $page | egrep -i "b23aee"`" ]; then
		touch $alarm
		mv $id $id.0
		cat $page | egrep -i "FF0000|FFB329|FFFF00|B23AEE|63B8FF" | egrep -i "db|dirm|ora|rac|eastsr|activecharge|dukeac|eastptixl0[12]" >> $alarm
		cat $page | egrep -i "b23aee" >>$alarm
		sed -i 's/.*VALUE="\([0-9][0-9]*\)".*/\1/g' $alarm
		sort -gu $alarm > $id
		rm -r $alarm
		diff $id $id.0 | grep '<'
		if [ $? = 0 ]; then
			mplayer $sound
			count=1
		else
			if [ $count -lt $count_times ]; then
				mplayer $sound
				count=`expr $count + 1`
			fi
		fi	
	fi
    sleep 30
done
}&
