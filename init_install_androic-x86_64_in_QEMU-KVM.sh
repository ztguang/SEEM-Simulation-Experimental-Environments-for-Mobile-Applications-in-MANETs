#!/system/bin/sh

cd /sdcard/tmp

mount -o remount,rw /system
mount -o remount,rw /
mkdir -p /system/xbin/quagga/etc

cp out/etc/zebra.conf /system/xbin/quagga/etc/
cp out/etc/ospf6d.conf /system/xbin/quagga/etc/

cp -r out/sbin/ /system/xbin/quagga/
cp out/lib/libzebra.so /system/lib64/
cp out/lib/libospf.so /system/lib64/
cp out/lib/libospfapiclient.so /system/lib64/
cp out/lib/libstlport_shared.so /system/lib64/
cp out/lib/libc++_shared.so /system/lib64/

cp out/busybox-x86_64 /system/xbin/
cp out/init_in_android-x86_64.sh /system/xbin/
cp out/chrome_51.0.2704.81.apk /sdcard/Download/chrome_51.0.2704.81.apk

chmod 755 /system/xbin/init_in_android-x86_64.sh
chmod 755 /system/xbin/busybox-x86_64

cd -
