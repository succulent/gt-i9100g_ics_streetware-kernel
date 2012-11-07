#!/bin/bash

reset

KERNEL_VERSION=$(cat `find -type f -name android_t1_omap4430_streetware_defconfig` | grep CONFIG_LOCALVERSION | head -n 1 | awk -F \" '{print $2}' | awk '{print substr($0,2)}')

if [ -f $KERNEL_VERSION.tar.md5 -a -f $KERNEL_VERSION.zip -a -f $KERNEL_VERSION.zip.md5 ];
then
	echo -n "[upload.sh] password for street79@street79.bplaced.net: "

	read -s PASSWORD

	if [ `echo $PASSWORD | md5sum | awk '{print $1}'` != 96df1b8d1bbbcb8a91ba10e09a1609f7 ];
	then
		echo
		echo
		echo "wrong password!"
		echo

		exit
	fi;

	clear

	./ftpput --user=street79 --pass=$PASSWORD --server=street79.bplaced.net --dir=/download/gt-i9100g_ics_streetware-kernel --binary --passive --verbose $KERNEL_VERSION.tar.md5

	echo

	./ftpput --user=street79 --pass=$PASSWORD --server=street79.bplaced.net --dir=/download/gt-i9100g_ics_streetware-kernel --binary --passive --verbose $KERNEL_VERSION.zip

	echo

	./ftpput --user=street79 --pass=$PASSWORD --server=street79.bplaced.net --dir=/download/gt-i9100g_ics_streetware-kernel --ascii --passive --verbose $KERNEL_VERSION.zip.md5

	echo

	echo `echo $KERNEL_VERSION | tail -c 6` > .latest_version

	./ftpput --user=street79 --pass=$PASSWORD --server=street79.bplaced.net --dir=/download/gt-i9100g_ics_streetware-kernel --ascii --passive --verbose .latest_version

	rm -f .latest_version

	echo
else
	if [ ! -f $KERNEL_VERSION.tar.md5 ];
	then
		echo "'$KERNEL_VERSION.tar.md5' not found!"
	fi;

	if [ ! -f $KERNEL_VERSION.zip ];
	then
		echo "'$KERNEL_VERSION.zip' not found!"
	fi;

	if [ ! -f $KERNEL_VERSION.zip.md5 ];
	then
		echo "'$KERNEL_VERSION.zip.md5' not found!"
	fi;

	echo
fi;

exit

