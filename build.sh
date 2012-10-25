#!/bin/sh

clear

#
# setup variables and directories
#

KERNEL_VERSION="streetware-ics-kernel-1.0.0"

WORK_DIRECTORY=`readlink -f .`

CROSS_COMPILER_DIRECTORY="$WORK_DIRECTORY/arm-eabi-4.4.3"

CWM_DIRECTORY="$WORK_DIRECTORY/cwm-source"

INITRAMFS_SOURCE_DIRECTORY="$WORK_DIRECTORY/initramfs-source"

KERNEL_DIRECTORY="$WORK_DIRECTORY/kernel-source"

INITRAMFS_DIRECTORY="$KERNEL_DIRECTORY/initramfs-source"

CONFIG_FILE="$KERNEL_DIRECTORY/arch/arm/configs/android_t1_omap4430_streetware_defconfig"

#
# check for existing files
#

if [ `find -maxdepth 1 \( -name $KERNEL_VERSION.tar.md5 -o -name $KERNEL_VERSION.zip \) -type f | wc -l` -ne 0 ];
then
	echo
	echo "please remove these files:"
	echo
	find -maxdepth 1 \( -name $KERNEL_VERSION.tar.md5 -o -name $KERNEL_VERSION.zip \) -type f -exec sh -c 'basename $0' {} \;
	echo
	exit
fi;

#
# make mrproper
#

echo
echo "make mrproper... \c"
cd $KERNEL_DIRECTORY
make -s mrproper > /dev/null
cd $WORK_DIRECTORY
echo "done."

#
# setup initramfs directory
#

echo
echo "setup initramfs directory... \c"
mkdir $INITRAMFS_DIRECTORY
cp -a $INITRAMFS_SOURCE_DIRECTORY $KERNEL_DIRECTORY
echo "done."

#
# remove placeholders
#

echo
echo "remove placeholders... \c"
find $INITRAMFS_DIRECTORY -name README -delete
echo "done."

#
# copy readme
#

echo
echo "copy 'README'... \c"
cp -a $WORK_DIRECTORY/README $INITRAMFS_DIRECTORY/misc/streetware/README
echo "done."

#
# copy config
#

echo
echo "copy '.config'... \c"
cp -a $CONFIG_FILE $KERNEL_DIRECTORY/.config
echo "done."

#
# make menuconfig
#

echo
echo "make menuconfig..."
echo
cd $KERNEL_DIRECTORY
make -s menuconfig || exit 1
cd $WORK_DIRECTORY
echo
echo "make menuconfig... done."

#
# compile modules
#

echo
echo "compile modules... \c"
cd $KERNEL_DIRECTORY
make -s -j8 modules > /dev/null || exit 1
cd $WORK_DIRECTORY
echo "done."

#
# copy modules
#

echo
echo "copy modules... \c"
cd $KERNEL_DIRECTORY
for i in $(find -name *.ko | grep .ko | grep './')
do
cp -a $i $INITRAMFS_DIRECTORY/lib/modules/
done
cd $WORK_DIRECTORY
echo "done."

#
# strip modules
#

echo
echo "strip modules... \c"
cd $INITRAMFS_DIRECTORY/lib/modules
for i in $(find . | grep .ko | grep './')
do
$CROSS_COMPILER_DIRECTORY/bin/arm-eabi-strip --strip-unneeded $i
done
cd $WORK_DIRECTORY
echo "done."

#
# compile kernel
#

echo
echo "compile kernel..."
echo
cd $KERNEL_DIRECTORY
make -s -j2 zImage > /dev/null || exit 1
cd $WORK_DIRECTORY
echo
echo "compile kernel... done."

#
# create tar archive
#

echo
echo "create '$KERNEL_VERSION.tar.md5'... \c"
cd $KERNEL_DIRECTORY/arch/arm/boot
tar cf $WORK_DIRECTORY/$KERNEL_VERSION.tar zImage  > /dev/null
cd $WORK_DIRECTORY
md5sum -t $KERNEL_VERSION.tar >> $KERNEL_VERSION.tar
mv $KERNEL_VERSION.tar $KERNEL_VERSION.tar.md5
echo "done."

#
# create zip archive
#

echo
echo "create '$KERNEL_VERSION.zip'... \c"
cp -f $KERNEL_DIRECTORY/arch/arm/boot/zImage $CWM_DIRECTORY/zip-source/
cd $CWM_DIRECTORY/zip-source/
zip -r $WORK_DIRECTORY/unsigned_$KERNEL_VERSION.zip * > /dev/null
cd $WORK_DIRECTORY
java -jar $CWM_DIRECTORY/java-sign/signapk.jar $CWM_DIRECTORY/java-sign/testkey.x509.pem $CWM_DIRECTORY/java-sign/testkey.pk8 unsigned_$KERNEL_VERSION.zip $KERNEL_VERSION.zip > /dev/null
rm -f $CWM_DIRECTORY/zip-source/zImage
rm -f $WORK_DIRECTORY/unsigned_$KERNEL_VERSION.zip
echo "done."

#
# make mrproper
#

echo
echo "make mrproper... \c"
cd $KERNEL_DIRECTORY
make -s mrproper > /dev/null
cd $WORK_DIRECTORY
echo "done."

echo

exit

