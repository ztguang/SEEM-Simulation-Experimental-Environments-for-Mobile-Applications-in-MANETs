#!/system/bin/sh
# execute "sed -i '460a init_in_android-x86_64.sh' /system/etc/init.sh" in android-x86_64-6.0-rc1-0.vdi

# Note: /system/xbin/quagga/sbin/init_in_android-x86_64.sh will be called 4 times in /system/etc/init.sh [init, bootcomplete, hci, hci]

#--------------------------------------------------------------------
# Note: vi /etc/preloaded-classes, #android.net.NetworkPolicyManager
# otherwise, can't forward packages
#--------------------------------------------------------------------

# waiting a while, push init_in_android-x86_64.sh in create_vm(),
# due to that init_in_android-x86_64.sh may be exist in android-x86_64-6.0-rc1-[1-252].vdi
# if create android-x86_64-6.0-rc1-[1-252].vdi from scratch create, then can delete the following line. 

#sleep 15 

#stop netd

ipadd=`ifconfig eth0 |awk -F '[ :]+' 'NR==2 {print $4}'`
#echo ${ipadd}

if [ "${ipadd}" != "112.26.2.5" ]; then

	#sleep 30

	#log.sh 1

	# Note: 112.26.2.[1-254] for android, 112.26.1.[1-254] for docker(centos)
	# must to change the IP address for every Android
	# ifconfig eth0 down
	ifconfig eth0 112.26.2.5 netmask 255.255.0.0 up

	mount -o remount,rw /system
	mount -o remount,rw /
	mkdir -p /opt/android-on-linux/quagga/out/etc
	cp /system/xbin/quagga/etc/zebra.conf /opt/android-on-linux/quagga/out/etc/
	cp /system/xbin/quagga/etc/ospf6d.conf /opt/android-on-linux/quagga/out/etc/
	sed -i '21a \ router-id 10.1.0.5' /opt/android-on-linux/quagga/out/etc/ospf6d.conf

	#pkill zebra
	#pkill ospf6d
	#echo 1 > /proc/sys/net/ipv4/ip_forward

	#sleep 1
	/system/xbin/quagga/sbin/zebra -d
	/system/xbin/quagga/sbin/ospf6d -d
	stop netd
	date >> /data/ztg_tmp/timestamp.txt
	# then, mannually execute date >> /data/ztg_tmp/logcat1.txt && logcat >> /data/ztg_tmp/logcat1.txt && start netd && date >> /data/ztg_tmp/logcat2.txt && logcat >> /data/ztg_tmp/logcat2.txt && log.sh 2
fi

iptables -F
iptables -F -t nat
iptables -F -t mangle

#iptables -X
#iptables -X -t nat
#iptables -X -t mangle

#svc wifi disable
#svc data disable

#log.sh 2

echo 1 > /proc/sys/net/ipv4/ip_forward

