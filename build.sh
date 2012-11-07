#!/bin/bash

reset

KERNEL_VERSION="streetware-ics-kernel-1.0.0"

WORK_DIRECTORY=$PWD

CROSS_COMPILER_DIRECTORY="$WORK_DIRECTORY/arm-eabi-4.4.3"

CWM_DIRECTORY="$WORK_DIRECTORY/cwm-source"

INITRAMFS_SOURCE_DIRECTORY="$WORK_DIRECTORY/initramfs-source"

KERNEL_DIRECTORY="$WORK_DIRECTORY/kernel-source"

INITRAMFS_DIRECTORY="$KERNEL_DIRECTORY/initramfs-source"

CONFIG_FILE="$KERNEL_DIRECTORY/arch/arm/configs/android_t1_omap4430_streetware_defconfig"

if [ `find -maxdepth 1 \( -name $KERNEL_VERSION.tar.md5 -o -name $KERNEL_VERSION.zip -o -name $KERNEL_VERSION.zip.md5 \) -type f | wc -l` -ne 0 ];
then
	echo "please remove these files:"
	echo

	find -maxdepth 1 \( -name $KERNEL_VERSION.tar.md5 -o -name $KERNEL_VERSION.zip -o -name $KERNEL_VERSION.zip.md5 \) -type f -exec sh -c 'basename $0' {} \;

	echo

	exit
fi;

echo -n "make mrproper... "

cd $KERNEL_DIRECTORY

make -s mrproper > /dev/null

cd $WORK_DIRECTORY

echo "done."

echo
echo -n "setup initramfs directory... "

mkdir $INITRAMFS_DIRECTORY

cp -a $INITRAMFS_SOURCE_DIRECTORY $KERNEL_DIRECTORY

echo "done."

echo
echo -n "remove placeholders... "

find $INITRAMFS_DIRECTORY -name README -delete

echo "done."

echo
echo -n "copy readme... "

cp -a $WORK_DIRECTORY/README $INITRAMFS_DIRECTORY/misc/streetware/README

echo "done."

echo
echo -n "copy config... "

cp -a $CONFIG_FILE $KERNEL_DIRECTORY/.config

echo "done."

echo
echo "make menuconfig..."
echo

cd $KERNEL_DIRECTORY

make -s menuconfig || exit 1

cd $WORK_DIRECTORY

echo
echo "make menuconfig... done."

echo
echo "compile modules..."
echo

cd $KERNEL_DIRECTORY

make -s -j8 modules > /dev/null || exit 1

cd $WORK_DIRECTORY

echo
echo "compile modules... done."

echo
echo -n "copy modules... "

cd $KERNEL_DIRECTORY

for i in $(find -name *.ko | grep .ko | grep './')
do
	cp -a $i $INITRAMFS_DIRECTORY/lib/modules/
done

cd $WORK_DIRECTORY

echo "done."

echo
echo -n "strip modules... "

cd $INITRAMFS_DIRECTORY/lib/modules

for i in $(find . | grep .ko | grep './')
do
	$CROSS_COMPILER_DIRECTORY/bin/arm-eabi-strip --strip-unneeded $i
done

cd $WORK_DIRECTORY

echo "done."

echo
echo "compile kernel..."
echo

cd $KERNEL_DIRECTORY

make -s -j2 zImage > /dev/null || exit 1

cd $WORK_DIRECTORY

echo
echo "compile kernel... done."

echo
echo -n "create '$KERNEL_VERSION.zip'... "

cp -f $KERNEL_DIRECTORY/arch/arm/boot/zImage $CWM_DIRECTORY/zip-source/

cd $CWM_DIRECTORY/zip-source/

zip -r $WORK_DIRECTORY/unsigned_$KERNEL_VERSION.zip * > /dev/null

cd $WORK_DIRECTORY

java -jar $CWM_DIRECTORY/java-sign/signapk.jar $CWM_DIRECTORY/java-sign/testkey.x509.pem $CWM_DIRECTORY/java-sign/testkey.pk8 unsigned_$KERNEL_VERSION.zip $KERNEL_VERSION.zip > /dev/null

rm -f $CWM_DIRECTORY/zip-source/zImage
rm -f $WORK_DIRECTORY/unsigned_$KERNEL_VERSION.zip

echo "done."

echo
echo -n "create '$KERNEL_VERSION.zip.md5'... "

md5sum $KERNEL_VERSION.zip > $KERNEL_VERSION.zip.md5

echo "done."

echo
echo -n "create '$KERNEL_VERSION.tar.md5'... "

cd $KERNEL_DIRECTORY/arch/arm/boot

tar cf $WORK_DIRECTORY/$KERNEL_VERSION.tar zImage  > /dev/null

cd $WORK_DIRECTORY

md5sum -t $KERNEL_VERSION.tar >> $KERNEL_VERSION.tar

mv $KERNEL_VERSION.tar $KERNEL_VERSION.tar.md5

echo "done."

echo
echo -n "make mrproper... "

cd $KERNEL_DIRECTORY

make -s mrproper > /dev/null

cd $WORK_DIRECTORY

echo "done."

echo

exit

