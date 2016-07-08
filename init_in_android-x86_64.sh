#!/bin/bash
# execute "sed -i '459a init_in_android-x86_64.sh' /system/etc/init.sh" in android-x86_64-6.0-rc1-0.vdi

sleep 60

ifconfig eth0 down

# Note: 112.26.2.[1-254] for android, 112.26.1.[1-254] for docker(centos)
# must to change the IP address for every Android
ifconfig eth0 112.26.2.1 netmask 255.255.0.0 up

mount -o remount,rw /system
mount -o remount,rw /

mkdir -p /opt/android-on-linux/quagga/out/etc
cp /system/xbin/quagga/etc/zebra.conf /opt/android-on-linux/quagga/out/etc/
cp /system/xbin/quagga/etc/ospf6d.conf /opt/android-on-linux/quagga/out/etc/

#sed -i '21a \ router-id 10.1.2.$1' /opt/android-on-linux/quagga/out/etc/ospf6d.conf

pkill zebra
pkill ospf6d
sleep 1

/system/xbin/quagga/sbin/zebra -d
/system/xbin/quagga/sbin/ospf6d -d

