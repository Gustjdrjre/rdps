#!/usr/bin/bash
pointer=0
total_commands=15
while [ $pointer -le $total_commands ]
do

	case $pointer in
		0)	echo "hostname"
			hostname;;
		1)	echo "uptime"
			uptime;;
		2)	echo "df -k"
			df -k | less;;
		3)	echo "/var/adm/messages"
			tail -100 /var/adm/messages | egrep -i "sendmail|error|warn" | less;;
		4)	echo "ifconfig -a"
			ifconfig -a;;
		5)	echo "prtdiag"
			prtdiag | less;;
		6)	echo "metastat | grep -i need"
			metastat | grep -i need;;
		7)	echo "prstat"
			prstat;;
		8)	echo "top"
			top;;
		9)	echo "iostat -En"
			iostat -En | grep "rs: [0-9][0-9]";;
		10)	echo "mailq"
			mailq;;
		11)	echo "fmdump"
			fmdump;;
		12)	echo "vxprint -ht"
			vxprint -ht | egrep "^v|^pl" | awk '{print $4$5}' | grep -v 'ENABLEDACTIVE';;
		13)	echo "sudo vxtask list"
			sudo vxtask list;;
		14)	echo "hastatus -sum"
			sudo /opt/VRTS/bin/hastatus -sum;;
		15)	echo "lltstat -n"
			/sbin/lltstat -n;;
	esac

	read action 
		case  $action in
		        b)	pointer=`expr $pointer - 1`;;
			\r)	pointer=$pointer;;
			x)	pointer=`expr $total_commands + 1`;;
			*)	pointer=`expr $pointer + 1`;;
		esac

done
