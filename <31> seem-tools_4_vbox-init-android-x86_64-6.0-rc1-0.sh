#!/bin/sh

#------------------------------------------------------------------------------------------
# This init script (seem-tools-auto_create_vm_android.sh) is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2016-06-30
# 
# copy quagga to /system/xbin/quagga, refer to http://blog.csdn.net/ztguang/article/details/51768680
# that is: install_quagga-0.99.21mr2.2_on_android-x86_64_in_Fedora23.txt
#
#------------------------------------------------------------------------------------------

#adb connect 192.168.56.3 && adb -s 192.168.56.3 root
#sleep 1
#adb connect 192.168.56.3 && adb -s 192.168.56.3 root
#adb connect 192.168.56.3

adb shell mount -o remount,rw /system
adb shell mount -o remount,rw /

adb shell mkdir -p /system/xbin/quagga/etc

cd /opt/android-on-linux/quagga

adb push out/etc/zebra.conf /system/xbin/quagga/etc/
adb push out/etc/ospf6d.conf /system/xbin/quagga/etc/

adb push out/sbin/ /system/xbin/quagga/
adb push out/lib/libzebra.so /system/lib64/
adb push out/lib/libospf.so /system/lib64/
adb push out/lib/libospfapiclient.so /system/lib64/

adb push /opt/android-on-linux/android-ndk-r12/sources/cxx-stl/stlport/libs/x86_64/libstlport_shared.so /system/lib64/
adb push /opt/android-on-linux/android-ndk-r12/sources/cxx-stl/llvm-libc++/libs/x86_64/libc++_shared.so /system/lib64/

adb push /opt/share-vm/fedora23server-share/seem_init.sh /system/xbin/quagga/sbin/

adb push /opt/share-vm/fedora23server-share/init.sh /system/etc/

# mongoose, simplest_web_server, websocket_chat, index.html
# gedit /opt/share-vm/fedora23server-share/webserver/index.html
adb push /opt/share-vm/fedora23server-share/webserver /system/xbin/quagga/

adb push /opt/tools/busybox/busybox-x86_64 /system/xbin/

# need enter into UI, then can access /sdcard/Download/
adb push /opt/android-on-linux/apk/chrome_51.0.2704.81.apk /sdcard/Download/

# to press button [ACCEPT] in ANDROID GUI
adb shell pm install /sdcard/Download/chrome_51.0.2704.81.apk

# cp android-x86_64-6.0-rc1-0.vdi android-x86_64-6.0-rc1-1.vdi; cp android-x86_64-6.0-rc1-0.vdi android-x86_64-6.0-rc1-2.vdi; cp android-x86_64-6.0-rc1-0.vdi android-x86_64-6.0-rc1-3.vdi; cp android-x86_64-6.0-rc1-0.vdi android-x86_64-6.0-rc1-4.vdi; cp android-x86_64-6.0-rc1-0.vdi android-x86_64-6.0-rc1-5.vdi; 

# then, enter android, modify /system/xbin/quagga/sbin/seem_init.sh, replace 112.26.2.1 & 10.1.2.1

cd -

