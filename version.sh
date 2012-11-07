#!/bin/bash

reset

BUILD_SCRIPT=`find -type f -name build.sh`
STREETWARE_DEFCONFIG=`find -type f -name android_t1_omap4430_streetware_defconfig`
INIT_RC=`find -type f -name init.rc`
RECOVERY_RC=`find -type f -name recovery.rc`
UPDATER_SCRIPT=`find -type f -name updater-script`

CURRENT_VERSION=`cat $STREETWARE_DEFCONFIG | grep CONFIG_LOCALVERSION | head -n 1 | awk -F - '{print $5}' | tr -d \"`

echo "current version: $CURRENT_VERSION"
echo -n "new version: "

read NEW_VERSION

if [ -z $NEW_VERSION ];
then
	echo
	echo "nothing to change!"
	echo
elif [ ! -z `echo $NEW_VERSION | tr -d . | tr -d [0-9]` ];
then
	echo
	echo "wrong input: $NEW_VERSION"
	echo
elif [ `echo $NEW_VERSION | wc -c` -ne 6 ];
then
	echo
	echo "wrong input: $NEW_VERSION"
	echo
elif [ `echo $NEW_VERSION | tr -d .` -eq `echo $CURRENT_VERSION | tr -d .` ];
then
	echo
	echo "nothing to change!"
	echo
else
	sed -i "s/streetware-ics-kernel-$CURRENT_VERSION/streetware-ics-kernel-$NEW_VERSION/g" $BUILD_SCRIPT
	sed -i "s/streetware-ics-kernel-$CURRENT_VERSION/streetware-ics-kernel-$NEW_VERSION/g" $STREETWARE_DEFCONFIG
	sed -i "s/SWICSK_VERSION $CURRENT_VERSION/SWICSK_VERSION $NEW_VERSION/g" $INIT_RC
	sed -i "s/SWICSK_VERSION $CURRENT_VERSION/SWICSK_VERSION $NEW_VERSION/g" $RECOVERY_RC
	sed -i "s/streetware-ics-kernel-$CURRENT_VERSION/streetware-ics-kernel-$NEW_VERSION/g" $UPDATER_SCRIPT

	echo
	echo "version changed from '$CURRENT_VERSION' to '$NEW_VERSION'!"
	echo
	echo "remember to change the readme manually!"
	echo
fi;

exit

