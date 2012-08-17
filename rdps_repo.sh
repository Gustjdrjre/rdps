#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "Please run this script as root." 1>&2
	exit 1
fi

server=http://mirror.int.rdps-china.com

if [ "$1" = "remove" ]; then
	sed -i '/reposdir=\/etc\/yum.repos.rdps.d/d' /etc/yum.conf
	if [ -d /etc/yum.repos.rdps.d ]; then
			rm -rf /etc/yum.repos.rdps.d
	fi
	if [ -d /var/cache/yum/releases-rdps ]; then
		rm -rf /var/cache/yum/*rdps
	fi
	echo "Removal completed."
else
	sed -i '/reposdir=\/etc\/yum.repos.rdps.d/d' /etc/yum.conf
	sed -i 's/\[main\]/&\nreposdir=\/etc\/yum.repos.rdps.d/' /etc/yum.conf 
	if [ -d /etc/yum.repos.rdps.d ]; then
			rm -rf /etc/yum.repos.rdps.d
	fi
	mkdir /etc/yum.repos.rdps.d
	touch /etc/yum.repos.rdps.d/rdps.repo
	echo "
[releases-rdps]
name=releases
failovermethod=priority
baseurl=$server/fedora/releases/\$releasever/Everything/\$basearch/os/
enabled=1
gpgcheck=0


[updates-rdps]
name=updates
failovermethod=priority
baseurl=$server/fedora/updates/\$releasever/\$basearch/
enabled=1
gpgcheck=0


[free-releases-rdps]
name=free-releases
failovermethod=priority
baseurl=$server/rpmfusion/free/fedora/releases/\$releasever/Everything/\$basearch/os/
enabled=1
gpgcheck=0


[free-updates-rdps]
name=free-updates
failovermethod=priority
baseurl=$server/rpmfusion/free/fedora/updates/\$releasever/\$basearch/
enabled=1
gpgcheck=0


[nonfree-releases-rdps]
name=nonfree-releases
failovermethod=priority
baseurl=$server/rpmfusion/nonfree/fedora/releases/\$releasever/Everything/\$basearch/os/
enabled=1
gpgcheck=0


[nonfree-updates-rdps]
name=nonfree-updates
failovermethod=priority
baseurl=$server/rpmfusion/nonfree/fedora/updates/\$releasever/\$basearch/
enabled=1
gpgcheck=0 
" > /etc/yum.repos.rdps.d/rdps.repo
	uname -r | egrep "fc8|fc9" 2>&1 >/dev/null
	if [[ $? = "0" ]] ; then
		echo "
[updates-newkey-rdps]
name=updates-newkey
failovermethod=priority
baseurl=$server/fedora/updates/\$releasever/\$basearch.newkey/
enable=1
gpgcheck=0
" >> /etc/yum.repos.rdps.d/rdps.repo
	fi
	echo "Setup completed."
fi
