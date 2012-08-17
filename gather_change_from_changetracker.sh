#!/bin/bash

#What this script does is to combine details of the changes of the current day on change tracker to one html file. So we can refer to this html file to deal with change-resulted alarms instead of checking all the dockets on change tracker.
#victor.zhou@rdps-china.com.


#Defining directory and files
work_dir=/home/vv/Desktop
daylist=$work_dir/.daylist
monthlist=$work_dir/.monthlist
output=$work_dir/daily_change.html

#if open=0 then page won't be opened.
open=1

#The month list will be kept on the local machine till the next month. But changes can be resheduled sometimes, so month list might needs to be updated accordingly.
while getopts mF opt; do
	case $opt in
		m) rm -f $monthlist;;
		F) open=0;;
		\?) echo "Usage: -m: update the month list;
       -F: disable openning the file after downloading is completed.";
		   exit 1;;
	esac
done

#Inputting user name and password
echo "Please input your username:"
read user
echo "Please input your password:(don't press CTRL-C at this time)"
stty_orig=`stty -g`
stty -echo
read password
stty $stty_orig

#Downloading the monthlist or updating it if necessary.
if [ ! -f $monthlist ]; then
	echo "Downloading $monthlist..."
	wget --user=$user --password=$password --no-check-certificate "http://changetracker.corp.cox.com/tracker/calendar/?month=`date +"%m"`&year=`date +"%Y"`" -O- > $monthlist
	sed -i 's/\(<li>\)/\n\1/g' $monthlist
else 
	if [ `ls -l $monthlist | awk '{print $6}' | awk -F- '{print $1$2}'` != `date +"%Y%m"` ]; then
	echo "Updating $monthlist..."
	wget --user=$user --password=$password --no-check-certificate "http://changetracker.corp.cox.com/tracker/calendar/?month=`date +"%m"`&year=`date +"%Y"`" -O- > $monthlist
	sed -i 's/\(<li>\)/\n\1/g' $monthlist
	fi
fi	

#Getting the change list of the day.
grep `date +"%Y-%m-%d"` $monthlist > $daylist
sed -i 's/.*\([0-9]\{5\}\).*/\1/' $daylist
grep "^[0-9]\{5\}" $daylist > ./.changetracker_temp
sort -gu ./.changetracker_temp -o $daylist
rm ./.changetracker_temp

if [ -f $output ]; then
	rm -r $output
	touch $output
fi
echo "<html><title>Cox changes, updated `date +%m/%d/%Y,%H:%M`</title></html>" >> $output


#Downloading the detail information of each change and put them into one file.
for id in `cat $daylist`; do
	wget --user=$user --password=$password --no-check-certificate wget --user=$user --password=$password --no-check-certificate http://changetracker.corp.cox.com/tracker/docket/edit.php?did=$id -O- | sed 's/a class="black-bold" title="view docket DID\([0-9]\{5\}\)" href="\/tracker\/docket\/detail.php?did=\1"/a class="black-bold" title="view docket DID\1" href="http:\/\/changetracker.corp.cox.com\/tracker\/docket\/detail.php?did=\1"/g' >>$output
	echo "********************************************************************************************************************************************">>$output
	echo "<br><br><br><br><br><br><br><br><br><br>" >>$output
	echo "<br><br><br><br><br><br><br><br><br><br>" >>$output
	echo "<br><br><br><br><br><br><br><br><br><br>" >>$output
	echo "********************************************************************************************************************************************">>$output
done
rm -rf $daylist

echo
echo
echo "Downloading completed."

if [ $open = 1 ]; then
	echo "Openning file..."
	firefox $output &
	echo "Done."
fi
exit 0
