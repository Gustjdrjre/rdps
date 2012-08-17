#!/bin/bash
HOME="/rdps/mirror"
LOG_DIR="$HOME/log"
FEDORA_DES="$HOME/fedora"
RPMFUSION_DES="$HOME/rpmfusion"
FEDORA_SERVER=ftp.jaist.ac.jp/pub/Linux/Fedora
RPMFUSION_SERVER=download1.rpmfusion.org/rpmfusion
LOCK="$HOME/mirrorsync.lck"
REPO=(i386)
RELEASE=(8 9 10 11)
LOG_FILE="sync_$(date +%Y%m%d-%H).log"
	
[ ! -d $HOME/log ] && mkdir -p  $HOME/log
#[ -f $LOCK ] && exit 1
#touch "$LOCK"

# When receiving TERM or SIGKILL signal, on_die will be executed
on_die()
{
	# Insert a timestamp and close the log file
	echo ">> ---" >> "$LOG_DIR/$LOG_FILE"
	echo ">> Termed without finishing on $(date --rfc-3339=seconds)" >> "$LOG_DIR/$LOG_FILE"
	echo "=============================================" >> "$LOG_DIR/$LOG_FILE"
	# Remove the lock file and exit
	rm -f "$LOCK"
	exit 0
}

# Execute function on_die() receiving TERM or SIGKILL signal
trap 'on_die' SIGTERM SIGKILL SIGINT

# Create the log file and insert a timestamp
touch "$LOG_DIR/$LOG_FILE"
echo "=============================================" >> "$LOG_DIR/$LOG_FILE"
echo ">> Starting sync on $(date --rfc-3339=seconds)" >> "$LOG_DIR/$LOG_FILE"
echo ">> ---" >> "$LOG_DIR/$LOG_FILE"

# Sync each of the releases set in $RELEASE
for release in ${RELEASE[@]}; do
	# Sync each of the repositories set in $REPO
	for repo in ${REPO[@]}; do
		# Change $repo to lower case
		repo=$(echo $repo | tr [:upper:] [:lower:])
		FEDORA_SUBDIR=(releases/$release/Everything/$repo/os updates/$release/$repo)
		RPMFUSION_SUBDIR=(free/fedora/releases/$release/Everything/$repo/os free/fedora/updates/$release/$repo nonfree/fedora/releases/$release/Everything/$repo/os nonfree/fedora/updates/$release/$repo)
		for fedora_subdir in ${FEDORA_SUBDIR[@]}; do
			echo ">> Syncing $FEDORA_SERVER/$fedora_subdir/ to $FEDORA_DES/$fedora_subdir" >> "$LOG_DIR/$LOG_FILE"
			#mkdir -p $FEDORA_DES/$fedora_subdir
			rsync -rptlv --safe-links --delete-after --delay-updates --exclude=/debug/ rsync://$FEDORA_SERVER/$fedora_subdir/ $FEDORA_DES/$fedora_subdir >> "$LOG_DIR/$LOG_FILE"
			sleep 1
		done
		for rpmfusion_subdir in ${RPMFUSION_SUBDIR[@]}; do
			echo ">> Syncing $RPMFUSION_SERVER/$rpmfusion_subdir/ to $RPMFUSION_DES/$rpmfusion_subdir" >> "$LOG_DIR/$LOG_FILE"
			#mkdir -p $RPMFUSION_DES/$rpmfusion_subdir
			rsync -rptlv --safe-links --delete-after --delay-updates --exclude=/debug/ rsync://$RPMFUSION_SERVER/$rpmfusion_subdir/ $RPMFUSION_DES/$rpmfusion_subdir >> "$LOG_DIR/$LOG_FILE"
			sleep 1
		done 

		# Create $repo.lastsync file with timestamp which may be useful for users to know when the repository was last updated
		# date --rfc-3339=seconds > "$FEDORA_DES/$repo.lastsync"
		sleep 1 
	done
	sleep 1
done

NEWKEY_SUBDIR=(updates/8/i386.newkey updates/9/i386.newkey)
for newkey_subdir in ${NEWKEY_SUBDIR[@]}; do
	echo ">> Syncing $FEDORA_SERVER/$newkey_subdir/ to $FEDORA_DES/$newkey_subdir" >> "$LOG_DIR/$LOG_FILE"
	#mkdir -p $FEDORA_DES/$newkey_subdir
	rsync -rptlv --safe-links --delete-after --delay-updates --exclude=/debug/ rsync://$FEDORA_SERVER/$newkey_subdir/ $FEDORA_DES/$newkey_subdir >> "$LOG_DIR/$LOG_FILE"
	sleep 1
done	

# Insert another timestamp and close the log file
echo ">> ---" >> "$LOG_DIR/$LOG_FILE"
echo ">> Finished sync on $(date --rfc-3339=seconds)" >> "$LOG_DIR/$LOG_FILE"
echo "=============================================" >> "$LOG_DIR/$LOG_FILE"
echo "" >> "$LOG_DIR/$LOG_FILE"

# Remove the lock file and exit
#rm -f "$LOCK"
exit 0
