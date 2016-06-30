#!/bin/sh

#------------------------------------------------------------------------------------------
# This init script (seem-tools-auto_create_vm_android.sh) is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2016-06-30
# 
# copy quagga to /system/xbin/quagga, refer to http://blog.csdn.net/ztguang/article/details/51768680
# that is: install_quagga-0.99.21mr2.2_on_android-x86_64_in_Fedora23.txt
#
# adb -s ${eth0_vn_ip}:5555 shell sed -i '459a \ init_in_android-x86_64.sh' /system/etc/init.sh; \
# NOTE: in android-x86_64-6.0-rc1-0.vdi, 
# execute "sed -i '459a init_in_android-x86_64.sh' /system/etc/init.sh"
#------------------------------------------------------------------------------------------

adb connect 192.168.56.3 && adb -s 192.168.56.3 root
sleep 1
adb connect 192.168.56.3 && adb -s 192.168.56.3 root
adb connect 192.168.56.3

adb shell mount -o remount,rw /system
adb shell mount -o remount,rw /

adb shell mkdir -p /system/xbin/quagga/etc

cd /opt/android-on-linux/quagga

adb push out/etc/zebra.conf /system/xbin/quagga/etc/
adb push out/etc/ospf6d.conf /system/xbin/quagga/etc/

adb push out/sbin/ /system/xbin/quagga/
adb push out/lib/libzebra.so /lib64/
adb push out/lib/libospf.so /lib64/
adb push out/lib/libospfapiclient.so /lib64/

adb push /opt/android-on-linux/android-ndk-r12/sources/cxx-stl/stlport/libs/x86_64/libstlport_shared.so /lib64/
adb push /opt/android-on-linux/android-ndk-r12/sources/cxx-stl/llvm-libc++/libs/x86_64/libc++_shared.so /lib64/

adb push /opt/android-on-linux/apk/chrome_51.0.2704.81.apk /sdcard/Download/

# to press button [ACCEPT] in ANDROID GUI
adb shell pm install /sdcard/Download/chrome_51.0.2704.81.apk

# execute "sed -i '459a init_in_android-x86_64.sh' /system/etc/init.sh" in android-x86_64-6.0-rc1-0.vdi

cd -
