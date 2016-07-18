#!/system/bin/sh
#
#--------------------------------------------------------------------
# Note: vi /etc/preloaded-classes, #android.net.wifi.* , #android.net.EthernetManager , #android.net.Dhcp*
# recompiled android-x86-6.0-rc1
# otherwise, can't forward packages
# Note: /system/etc/init.sh will be called 4 times in /init.rc: [init, bootcomplete, hci, hci]
# seem_init.sh will be called twice in /system/etc/init.sh, that is, [init, bootcomplete]
#--------------------------------------------------------------------

# waiting a while, push init_in_android-x86_64.sh in create_vm(),
# due to that init_in_android-x86_64.sh may be exist in android-x86_64-6.0-rc1-[1-252].vdi
# if create android-x86_64-6.0-rc1-[1-252].vdi from scratch create, then can delete the following line. 

#ipadd=`ifconfig eth0 |awk -F '[ :]+' 'NR==2 {print $4}'`
#echo ${ipadd}

#if [ "${ipadd}" != "112.26.2.1" ]; then

if [ ! -f /opt/init.txt ]; then
	#mv /system/bin/dhcpcd /system/bin/dhcpcd.bac
	#pkill dhcpcd &>/dev/null

	#stop netd

	#sleep 2

	#log.sh 1

	# Note: 112.26.2.[1-254] for android, 112.26.1.[1-254] for docker(centos)
	# must to change the IP address for every Android
	#ifconfig eth0 down
	#ifconfig eth0 112.26.2.1 netmask 255.255.0.0 up

	mount -o remount,rw /system
	mount -o remount,rw /
	mkdir -p /opt/android-on-linux/quagga/out/etc
	cp /system/xbin/quagga/etc/zebra.conf /opt/android-on-linux/quagga/out/etc/
	cp /system/xbin/quagga/etc/ospf6d.conf /opt/android-on-linux/quagga/out/etc/
	sed -i '21a \ router-id 10.1.2.1' /opt/android-on-linux/quagga/out/etc/ospf6d.conf

	#ifconfig eth0 112.26.2.1 netmask 255.255.0.0 up

	#pkill zebra &>/dev/null
	#pkill ospf6d &>/dev/null
	#sleep 1

	#count=`ps |grep "system_server" |grep -v "grep" |wc -l`
	#while [ ! $count ]; do
	#	sleep 3
	#	count=`ps |grep "system_server" |grep -v "grep" |wc -l`
	#done

	/system/xbin/quagga/sbin/zebra -d
	/system/xbin/quagga/sbin/ospf6d -d

	touch /opt/init.txt
fi


	#iptables -F && iptables -F -t nat && iptables -F -t mangle       
	#iptables -X && iptables -X -t nat && iptables -X -t mangle   

	#ip6tables -F && ip6tables -F -t nat && ip6tables -F -t mangle
	#ip6tables -X && ip6tables -X -t nat && ip6tables -X -t mangle    

	echo 1 > /proc/sys/net/ipv4/ip_forward	   

	#stop netd

	#echo "stop netd" >> /data/ztg_tmp/timestamp.txt
	#cat /proc/sys/net/ipv4/ip_forward >> /data/ztg_tmp/timestamp.txt
	#date >> /data/ztg_tmp/timestamp.txt

	#log.sh 1

	# then, mannually execute log.sh 1 && date >> /data/ztg_tmp/logcat1.txt && logcat >> /data/ztg_tmp/logcat1.txt && start netd && date >> /data/ztg_tmp/logcat2.txt && logcat >> /data/ztg_tmp/logcat2.txt && log.sh 2

#fi

#svc wifi disable
#svc data disable

#log.sh 2

