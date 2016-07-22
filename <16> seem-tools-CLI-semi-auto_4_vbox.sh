#!/bin/sh

#------------------------------------------------------------------------------------------
# This tool (seem-tools-CLI-semi-auto_4_vbox.sh) is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2016-06-18
# 
# Note, Prerequisites for using this script:  You have already installed Docker and NS3.
# Path in my notebook:
# NS3: /opt/tools/network_simulators/ns3/ns-allinone-3.25/
#------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------
# (OK)(OK)(All in CLI) Fedora23 + Docker(centos-manet) + NS3 + MANETs - testing
#------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------
# function create_docker()
# Description:
# create $docker_node_num of dockers
# receive two parameters, that are docker_node_num, docker_image
#
# IP address scope: 112.26.1.${id}/16
#------------------------------------------------------------------------------------------

create_docker(){	

	# $1, that is, docker_node_num
	# $2, that is, docker_image

	# You will also have to make sure that your kernel has ethernet filtering (ebtables, bridge-nf,
	# arptables) disabled. If you do not do this, only STP and ARP traffic will be allowed to 
	# flow across your bridge and your whole scenario will not work.
	# if directory "/proc/sys/net/bridge" missing, I execute "modprobe br_netfilter" to get this directory again.

	if [ ! -d /proc/sys/net/bridge ]; then
		modprobe br_netfilter
	fi

	cd /proc/sys/net/bridge
	for f in bridge-nf-*; do echo 0 > $f; done
	cd -

	# [root@localhost ~]# man ip-netns
	# By convention a named network namespace is an object at /var/run/netns/NAME that can be opened.
	# The file descriptor resulting from opening /var/run/netns/NAME refers to the specified network
	# namespace. Holding that file descriptor open keeps the network namespace alive.
	# The file descriptor can be used with the setns(2) system
	# call to change the network namespace associated with a task.

	rm /var/run/netns -rf &>/dev/null
	mkdir -p /var/run/netns &>/dev/null

	# $1, that is, docker_node_num
	# $2, that is, docker_image

	for((id=1; id<=$1; id++))
	do

		# to determine whether docker_image exists
		vm_image="$2"
		exists=`docker images | awk -F \" '{print $1}' | grep ${vm_image} | wc -l | cat`
		if [ $exists -eq 0 ]; then
			echo "${vm_image} does not exist"
			exit
		fi

		# docker run -it --rm --net='none' --name "docker_${id}" centos-manet /bin/sh
		# gnome-terminal -x bash -c "docker run -it --rm --net='none' --name \"docker_${id}\" centos-manet /bin/sh"
		# gnome-terminal -x bash -c "docker run -it --rm --net='none' --name \"docker_${id}\" $2 /bin/sh"

		#gnome-terminal -x bash -c "docker run -it --rm --net='none' --name \"docker_${id}\" $2"
		# kernel network capabilities are not enabled by default.
		# You are going to need to run your container with --privileged
		gnome-terminal -x bash -c "docker run --privileged -it -d --net='none' --name \"docker_${id}\" $2"
		sleep 2
		docker exec docker_${id} /bin/sh -c "sed -i '21a \ router-id 10.1.1.${id}' /usr/local/etc/ospf6d.conf"
		docker exec docker_${id} /bin/sh -c "zebra -d &>/dev/null"
		docker exec docker_${id} /bin/sh -c "ospf6d -d &>/dev/null"

		# SET VARIABLES

		# get PID of CONTAINER
		pid=$(docker inspect -f '{{.State.Pid}}' "docker_${id}")

		bridge="br_d_${id}"
		tap="tap_d_${id}"
		veth="veth_${id}"
		deth="deth_${id}"

		brctl addbr ${bridge}

		ip link add ${veth} type veth peer name ${deth}
		brctl addif ${bridge} ${veth}
		ip link set ${veth} up
		# ifconfig ${veth} 0.0.0.0 promisc up

		ip link set ${deth} netns ${pid}

		tunctl -t ${tap}
		ifconfig ${tap} up
		# ifconfig ${tap} promisc up
		# ifconfig ${tap} 0.0.0.0 promisc up

		brctl addif ${bridge} ${tap}
		ifconfig ${bridge} up
		# ifconfig ${bridge} promisc up
		# ifconfig ${bridge} 0.0.0.0 promisc up

		ln -s /proc/${pid}/ns/net /var/run/netns/${pid}

		ip netns exec ${pid} ip link set dev ${deth} name eth0
		ip netns exec ${pid} ip link set eth0 up
		# ip netns exec ${pid} ip addr add 192.168.26.${id}/24 dev eth0
		ip netns exec ${pid} ip addr add 112.26.1.${id}/16 dev eth0
	done
}

#------------------------------------------------------------------------------------------
# function destroy_docker()
# Description:
# destroy $docker_node_num of dockers
# receive one parameter, that is docker_node_num
#------------------------------------------------------------------------------------------

destroy_docker(){

	# $1, that is, $docker_node_num
	for((id=1; id<=$1; id++))
	do
		bridge="br_d_${id}"
		tap="tap_d_${id}"
		veth="veth_${id}"

		ifconfig ${bridge} down &>/dev/null
		brctl delif ${bridge} ${tap} &>/dev/null
		brctl delbr ${bridge} &>/dev/null

		ifconfig ${tap} down &>/dev/null
		tunctl -d ${tap} &>/dev/null
		ifconfig ${veth} down &>/dev/null

		docker stop "docker_${id}" &>/dev/null
		docker rm "docker_${id}" &>/dev/null
	done
}


#------------------------------------------------------------------------------------------
# So far, OK OK OK
#------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------
# (OK)(OK)(All in CLI) running two Android-x86 which connect to NS3(MANETs) via "ethernet bridge"
#--------------------------------------------------------------------------
# ip route add 192.168.26.0/24 dev br_a_1
# adb devices
# adb root

# adb connect 192.168.56.101:5555
# adb devices
# adb -s 192.168.56.101:5555 root
# adb -s 192.168.56.101:5555 shell

# adb disconnect 192.168.56.102:5555

# VBoxManage controlvm android-x86_64-6.0-rc1-1 poweroff

#------------------------------------------------------------------------------------------
# function create_android()
# Description:
# create $android_node_num of dockers
# receive three parameters, that are docker_node_num, android_node_num, VM_image
#
# IP address scope: 112.26.2.${id}/16
#------------------------------------------------------------------------------------------

create_android(){	

	# $1, that is, docker_node_num
	# $2, that is, android_node_num
	# $3, that is, VM_image
	# $4, that is, PATH of *.vdi

	# You will also have to make sure that your kernel has ethernet filtering (ebtables, bridge-nf,
	# arptables) disabled. If you do not do this, only STP and ARP traffic will be allowed to 
	# flow across your bridge and your whole scenario will not work.

	if [ ! -d /proc/sys/net/bridge ]; then
		modprobe br_netfilter
	fi

	cd /proc/sys/net/bridge
	for f in bridge-nf-*; do echo 0 > $f; done
	cd -

	for((id=1; id<=$2; id++))
	do

		# to determine whether VM_image exists
		# vm_image=$3${id}
		# exists=`VBoxManage list vms | awk -F \" '{print $2}' | grep ${vm_image} | wc -l | cat`
		# if [ $exists -eq 0 ]; then
		# 	echo "${vm_image} does not exist"
		# 	exit
		# fi

		# SET VARIABLES
		bridge="br_a_${id}"
		tap="tap_a_${id}"

		# look at VirtualBox Gloable Setting, that is, vboxnet0: 192.168.56.1, 192.168.56.2(DHCPD), (3-254)
		#host0=$[2+id]
		#eth0_a_ip="192.168.56.${host0}"

		#eth0_a_ip="112.26.2.${id}"

		tunctl -t ${tap}
		#ip link set up dev ${tap}
		#ifconfig ${tap} 0.0.0.0 promisc up
		ifconfig ${tap} up
		brctl addbr ${bridge}
		brctl addif ${bridge} ${tap}
		#ip link set up dev ${bridge}
		ifconfig ${bridge} up
		#ifconfig ${bridge} 0.0.0.0 promisc up

		# VBoxManage modifyvm android-x86_64-6.0-rc1-${id} --memory 1024 --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0  --nic2 bridged --bridgeadapter2 ${bridge}
		# VBoxManage startvm android-x86_64-6.0-rc1-${id}
		# gnome-terminal -x bash -c "VBoxManage startvm android-x86_64-6.0-rc1-${id}"

		# VBoxManage hostonlyif create
		# VBoxManage hostonlyif ipconfig vboxnet0 --ip 10.0.0.10 --netmask 255.255.255.0

		# VBoxManage list hostonlyifs
		# VBoxManage list dhcpservers
		# VBoxManage list bridgedifs

		# VBoxManage modifyvm $3${id} --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0 --nic2 bridged --bridgeadapter2 ${bridge}
		# NOTE: (vboxnet0 - 192.168.56) (vboxnet1 - 192.168.57) (vboxnet2 - 192.168.58)
		# VBoxManage modifyvm $3${id} --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0 --nic2 bridged --bridgeadapter2 ${bridge} --nic3 none --nic4 none


		# gnome-terminal -x bash -c "VBoxManage startvm $3${id}"

		# sleep 30
		# 
		# adb connect ${eth0_a_ip}
		# sleep 1
		# adb -s ${eth0_a_ip}:5555 root
		# sleep 1
		# adb connect ${eth0_a_ip}
		# sleep 1
		# adb -s ${eth0_a_ip}:5555 root
		# sleep 1
		# adb connect ${eth0_a_ip}

		# adb -s ${eth0_a_ip}:5555 shell mkdir -p /opt/android-on-linux/quagga/out/etc
		# adb -s ${eth0_a_ip}:5555 shell cp /system/xbin/quagga/etc/zebra.conf /opt/android-on-linux/quagga/out/etc/
		# adb -s ${eth0_a_ip}:5555 shell cp /system/xbin/quagga/etc/ospf6d.conf /opt/android-on-linux/quagga/out/etc/
		# adb -s ${eth0_a_ip}:5555 shell /system/xbin/quagga/zebra -d
		# adb -s ${eth0_a_ip}:5555 shell /system/xbin/quagga/ospf6d -d

		# adb -s ${eth0_a_ip}:5555 shell ifconfig eth1 down
		# adb -s ${eth0_a_ip}:5555 shell ifconfig eth1 ${eth0_a_ip} netmask 255.255.255.0 up
		# adb -s ${eth0_a_ip}:5555 shell ifconfig eth0 down

		# VBoxManage createvm --name android-x86_64-6.0-rc1-1 --ostype Linux_64 --register
		# VBoxManage modifyvm android-x86_64-6.0-rc1-1 --memory 1024 --vram 128 --usb off --audio pulse --audiocontroller sb16 --acpi on --rtcuseutc off --boot1 disk --boot2 dvd --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0
		# VBoxManage storagectl android-x86_64-6.0-rc1-1 --name "IDE Controller" --add ide --controller PIIX4
		# VBoxManage storageattach android-x86_64-6.0-rc1-1 --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium android-x86_64-6.0-rc1-1.vdi
		# VBoxManage startvm android-x86_64-6.0-rc1-1

		# --nic1 bridged --nictype1 Am79C973 --nictrace1 on --nictracefile1 $nictracefile${id} --bridgeadapter1 ${bridge}
		# nictracefile="/root/tmp/nictracefile_"

# VBoxManage storagectl $3${id} --name \"IDE Controller\" --add ide --controller PIIX4; \
# VBoxManage internalcommands sethduuid $4/$3${id}.vdi; \

		echo "VBoxManage startvm $3${id}"

		gnome-terminal -x bash -c "VBoxManage createvm --name $3${id} --ostype Linux_64 --register; \
VBoxManage modifyvm $3${id} --memory 1024 --vram 128 --usb off --audio pulse --audiocontroller sb16 --acpi on --rtcuseutc off --boot1 disk --boot2 dvd --nic1 bridged --nictype1 Am79C973 --bridgeadapter1 ${bridge} --nic2 none --nic3 none --nic4 none; \
VBoxManage storagectl $3${id} --name \"IDE Controller\" --add ide --controller PIIX4; \
VBoxManage internalcommands sethduuid $4/$3${id}.vdi; \
VBoxManage storageattach $3${id} --storagectl \"IDE Controller\" --port 0 --device 0 --type hdd --medium $4/$3${id}.vdi; \
VBoxManage startvm $3${id}; \
sleep 100"

	done
}


#------------------------------------------------------------------------------------------
# function destroy_android()
# Description:
# destroy $android_node_num of androids
# receive two parameters, that are android_node_num, VM_image
#------------------------------------------------------------------------------------------

destroy_android(){

	# $1, that is, $android_node_num
	# $2, that is, VM_image

	for((id=1; id<=$1; id++))
	do
		echo "VBoxManage controlvm $2${id} poweroff"

		VBoxManage controlvm $2${id} poweroff &>/dev/null
		VBoxManage unregistervm $2${id} &>/dev/null
		rm "/root/VirtualBox VMs/$2${id}" -rf &>/dev/null

		sleep 1

		bridge="br_a_${id}"
		tap="tap_a_${id}"

		ifconfig ${bridge} down &>/dev/null
		brctl delif ${bridge} ${tap} &>/dev/null
		brctl delbr ${bridge} &>/dev/null

		ifconfig ${tap} down &>/dev/null
		tunctl -d ${tap} &>/dev/null
	done
}


#------------------------------------------------------------------------------------------
# usage() 
# script usage
#------------------------------------------------------------------------------------------
usage(){
	cat <<-EOU
    Usage: seem-tools-CLI-semi-auto_4_vbox.sh a b c d e f
        a, the value is create or destroy
        b, the number of dockers to be created
        c, the number of androids to be created
        d, docker image, such as, busybox or ubuntu, etc.
        e, Android image, such as, android-x86_64-6.0-rc1-
        f, the path of Android image, such as, /opt/virtualbox-os/

        Note: b + c <= 254

    For example:
        [root@localhost fedora23server-share]# pwd
            /opt/share-vm/fedora23server-share
        [root@localhost fedora23server-share]# ls seem-tools-CLI-semi-auto_4_vbox.sh
            seem-tools-CLI-semi-auto_4_vbox.sh
        [root@localhost fedora23server-share]#

        ./seem-tools-CLI-semi-auto_4_vbox.sh create 25 0 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi
        ./seem-tools-CLI-semi-auto_4_vbox.sh destroy 25 0 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi

        ./seem-tools-CLI-semi-auto_4_vbox.sh create 0 5 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi
        ./seem-tools-CLI-semi-auto_4_vbox.sh destroy 0 5 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi

        ./seem-tools-CLI-semi-auto_4_vbox.sh create 20 5 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi
        ./seem-tools-CLI-semi-auto_4_vbox.sh destroy 20 5 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi

	EOU
}


#------------------------------------------------------------------------------------------
# function create_ns3_manet_seem_cc()
# receive two parameter, that is docker_node_num, android_node_num
#------------------------------------------------------------------------------------------

create_ns3_manet_seem_cc(){
	echo "create seem-manet.cc from seem-manet-template.cc"

	cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25/scratch
	rm seem-manet.cc -f &>/dev/null
	cp seem-manet-template.cc seem-manet.cc

	# after the 306 line of /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25/scratch/seem-manet-template.cc
	str='306a \\n  '

	for((id=1; id<=$1; id++))
	do
		tap="tap_d_${id}"
		ns=$[id-1]
		# inter="tapBridge.SetAttribute (\"Gateway\", Ipv4AddressValue (\"192.168.26.${id}\")); tapBridge.SetAttribute (\"DeviceName\", StringValue (\"${tap}\"));\n  tapBridge.Install (adhocNodes.Get (${id}), adhocDevices.Get (${id}));\n  "
		inter="tapBridge.SetAttribute (\"DeviceName\", StringValue (\"${tap}\"));\n  tapBridge.Install (adhocNodes.Get (${ns}), adhocDevices.Get (${ns}));\n  "
		#inter="tapBridge.SetAttribute (\"DeviceName\", StringValue (\"${tap}\"));\n  "
		str=${str}${inter}
	done

	# a: docker_node_num, b:android_node_num
	#host1=$[$1+1]
	#a=$1
	#b=$2
	#for((id=$[a+1]; id<=$[a+b]; id++))

	for((ns=$1, id=1; id<=$2; id++, ns++))
	do
		tap="tap_a_${id}"
		#ns=$[n-1]
		#inter="tapBridge.SetAttribute (\"Gateway\", Ipv4AddressValue (\"192.168.26.${host1}\")); tapBridge.SetAttribute (\"DeviceName\", StringValue (\"${tap}\"));\n  tapBridge.Install (adhocNodes.Get (${id}), adhocDevices.Get (${id}));\n  "
		inter="tapBridge.SetAttribute (\"DeviceName\", StringValue (\"${tap}\"));\n  tapBridge.Install (adhocNodes.Get (${ns}), adhocDevices.Get (${ns}));\n  "
		#inter="tapBridge.SetAttribute (\"DeviceName\", StringValue (\"${tap}\"));\n  "

		str=${str}${inter}

		#host1=$[host1+1]
	done

	# sed -i '306a \\n  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_1"));\n  tapBridge.Install (adhocNodes.Get (0), adhocDevices.Get (0));\n  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_2"));\n  tapBridge.Install (adhocNodes.Get (0), adhocDevices.Get (0));' seem-manet.cc

	sed -i "${str}" seem-manet.cc

	cd -
}


#------------------------------------------------------------------------------------------
# function start_ns3()
#------------------------------------------------------------------------------------------

start_ns3(){
	echo "RUNNING SIMULATION, press CTRL-C to stop it"

	cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25

	./waf --run scratch/seem-manet --vis &

#	./waf --run scratch/seem-manet-5-android --vis

	cd -
}


#------------------------------------------------------------------------------------------
# ./seem-tools-CLI-semi-auto_4_vbox.sh para1 para2 para3 para4 para5 para6
# para1 ($1), that is, the value is create or destroy
# para2 ($2), that is, the number of dockers to be created
# para3 ($3), that is, the number of androids to be created
# para4 ($4), that is, docker image, such as, busybox or ubuntu, etc.
# para5 ($5), that is, Android image, such as, android-x86_64-6.0-rc1-
# para6 ($6), that is, the path of Android image, such as, /opt/virtualbox-os/
# [root@localhost virtualbox-os]# pwd
# /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os
# [root@localhost virtualbox-os]# ls
# android-x86_64-6.0-rc1-1.vdi  android-x86_64-6.0-rc1-2.vdi  android-x86_64-6.0-rc1-3.vdi  android-x86_64-6.0-rc1-4.vdi
# 
# ./seem-tools-CLI-semi-auto_4_vbox.sh create 25 0 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi
# ./seem-tools-CLI-semi-auto_4_vbox.sh destroy 25 0 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi
# 
# ./seem-tools-CLI-semi-auto_4_vbox.sh create 0 5 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi
# ./seem-tools-CLI-semi-auto_4_vbox.sh destroy 0 5 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi
# 
# ./seem-tools-CLI-semi-auto_4_vbox.sh create 20 5 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi
# ./seem-tools-CLI-semi-auto_4_vbox.sh destroy 20 5 centos-manet android-x86_64-6.0-rc1-  PATH_of_*.vdi
#------------------------------------------------------------------------------------------

# docker search image_name
# docker pull image_name
# docker images
# docker rmi image_name
# docker run --privileged -i -t -d --net=none --name docker_$id $docker_image -t $type -i $id
# docker ps

# systemctl start docker.service

# the number of dockers and androids should be less than 254,
# if you have more nodes in your emulation environment, you can modify corresponding code.

a=$2
b=$3

if [ $# -eq 6 ]; then

	if [ $[a+b] -gt 254 ] || [ $2 -lt 0 ] || [ $3 -lt 0 ] || !([ $1 == "create" ]||[ $1 == "destroy" ]); then
		usage
		exit
	fi

	case $1 in
		create)
			if [ $2 -gt 0 ]; then create_docker $2 $4; fi
			if [ $3 -gt 0 ]; then create_android $2 $3 $5 $6; fi
			if [ $[a+b] -gt 0 ]; then
				create_ns3_manet_seem_cc $2 $3

	# waiting a while, push init_in_android-x86_64.sh in create_vm(),
	# due to that init_in_android-x86_64.sh may be exist in android-x86_64-6.0-rc1-[1-252].vdi
	# if create android-x86_64-6.0-rc1-[1-252].vdi from scratch create, then can delete the following line. 
	# look at seem-tools-auto_create_vm_android.sh
				sleep 60

				start_ns3
			fi
		;;
		destroy)
			if [ $2 -gt 0 ]; then
				destroy_docker $2
				rm /var/run/netns -rf &>/dev/null
			fi

			if [ $3 -gt 0 ]; then
				destroy_android $3 $5
				ifconfig vboxnet0 down &>/dev/null
			fi

			pkill seem-manet
		;;
	esac
else
	usage
fi

# [root@localhost virtualbox-os]# pwd
# /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os
# [root@localhost virtualbox-os]# ls
# android-x86_64-6.0-rc1-0.vdi  android-x86_64-6.0-rc1-2.vdi  android-x86_64-6.0-rc1-4.vdi
# android-x86_64-6.0-rc1-1.vdi  android-x86_64-6.0-rc1-3.vdi  android-x86_64-6.0-rc1-5.vdi
# [root@localhost virtualbox-os]# 



#-----------------------------------------------------------------------------
# 25 docker (centos)
#-----------------------------------------------------------------------------
# systemctl start docker.service
# systemctl status docker.service

# [root@localhost fedora23server-share]# pwd
# /opt/share-vm/fedora23server-share

# ./seem-tools-CLI-semi-auto_4_vbox.sh create 25 0 centos-manet android-x86_64-6.0-rc1- /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

# ./seem-tools-CLI-semi-auto_4_vbox.sh destroy 25 0 centos-manet android-x86_64-6.0-rc1- /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

# cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25
# ./waf --run scratch/seem-manet --vis
# ./waf --run scratch/seem-manet-25-docker --vis
# ./waf --run scratch/seem-manet-5-docker --vis
#
# [root@localhost tmp]# tcpdump -vv -n -i br_d_1
#
# docker run --privileged -it -d --name "docker_1" centos-manet
# docker ps -a
# docker attach docker_1
# docker stop docker_1
# docker start docker_1
# docker rm docker_1

# docker ps
# docker rmi 2c067614b89f

# [root@localhost tmp]# tcpdump -i veth_1 > veth_1.txt
# [root@localhost tmp]# gedit veth_1.txt



#-----------------------------------------------------------------------------
# 5 android-x86_64
#-----------------------------------------------------------------------------
#
# [root@localhost fedora23server-share]# pwd
# /opt/share-vm/fedora23server-share

# ./seem-tools-CLI-semi-auto_4_vbox.sh create 0 5 centos-manet android-x86_64-6.0-rc1- /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os
#
# ./seem-tools-CLI-semi-auto_4_vbox.sh destroy 0 5 centos-manet android-x86_64-6.0-rc1- /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os
#
# cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25
# ./waf --run scratch/seem-manet --vis
# ./waf --run scratch/seem-manet-5-android --vis

#-----------------------------------------------------------------------------
# 20 docker (centos) and 5 android-x86_64, automatically.
#-----------------------------------------------------------------------------
#
# [root@localhost fedora23server-share]# pwd
# /opt/share-vm/fedora23server-share

# ./seem-tools-CLI-semi-auto_4_vbox.sh create 20 5 centos-manet android-x86_64-6.0-rc1- /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os
#
# ./seem-tools-CLI-semi-auto_4_vbox.sh destroy 20 5 centos-manet android-x86_64-6.0-rc1- /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

#-----------------------------------------------------------------------------

#
# busybox route add -host 112.26.2.1 dev eth0
# busybox route add -host 112.26.2.1 gw 112.26.2.254

# [root@localhost tmp]# pwd
# /root/tmp
# [root@localhost tmp]# ls
# nictracefile_1  nictracefile_2  nictracefile_3  nictracefile_4  nictracefile_5  t.txt
# [root@localhost tmp]# tcpdump -r nictracefile_1
# [root@localhost tmp]# tcpdump -r nictracefile_1 > nictracefile_1.txt
# [root@localhost tmp]# gedit nictracefile_1.txt

# [root@localhost tmp]# tcpdump -i vboxnet0 > vboxnet0.txt
# [root@localhost tmp]# tcpdump -i vboxnet0 ip6 > vboxnet0.txt
# [root@localhost tmp]# tcpdump -i br_a_1 > br_a_1.txt
# [root@localhost tmp]# tcpdump -i br_a_2 ip6 > br_a_2.txt
# [root@localhost tmp]# tcpdump -ne -i br_a_2 ip6 > br_a_2.txt

# [root@localhost tmp]# tcpdump -vv -n -i br_a_1

# have you enabled IPv6 on the interface at all? if the bridge device is br_a_1, then do this:
# sysctl net.ipv6.conf.br_a_1.disable_ipv6=0
# sysctl net.ipv6.conf.br_a_1.autoconf=1
# sysctl net.ipv6.conf.br_a_1.accept_ra=1
# sysctl net.ipv6.conf.br_a_1.accept_ra_defrtr=1
# less /proc/sys/net/ipv6/conf/br_a_1/disable_ipv6

# Every IPv6 address, even link-local ones, automatically subscribe to a multicast group based on its last 24 bits. If multicast snooping is enabled, the bridge filters out (almost) all multicast traffic by default. When an IPv6 address is assigned to an interface, the system must inform the network that this interface is interested in that particular multicast group and must be excluded by the filter. The following is a good introductory video: https://www.youtube.com/watch?v=O1JMdjnn0ao
# Multicast snooping is there to prevent flooding the network with multicast packets that most systems aren't interested. You can disable multicast snooping in small deployments without noticing any big difference. But this may have significant performance impact on larger deployments.   You can disable snooping with:
# echo -n 0 > /sys/class/net/br_a_1/bridge/multicast_snooping
# echo -n 0 > /sys/class/net/br_a_2/bridge/multicast_snooping
# echo -n 0 > /sys/class/net/br_a_3/bridge/multicast_snooping
# echo -n 0 > /sys/class/net/br_a_4/bridge/multicast_snooping
# echo -n 0 > /sys/class/net/br_a_5/bridge/multicast_snooping

# If you want to protect your VMs from unwanted traffic and unnecessary packet processing, you can leave snooping enabled but also enable a multicast Querier on the network. A Querier will periodically broadcast query packets and update snooping filters on switches and bridges. It is possible to enable a Querier on your system with:
# echo -n 1 > /sys/class/net/br_a_1/bridge/multicast_querier
# echo -n 1 > /sys/class/net/br_a_2/bridge/multicast_querier
# echo -n 1 > /sys/class/net/br_a_3/bridge/multicast_querier
# echo -n 1 > /sys/class/net/br_a_4/bridge/multicast_querier
# echo -n 1 > /sys/class/net/br_a_5/bridge/multicast_querier

# ip -6 nei
# ip -4 neighbor

# setprop service.adb.tcp.port 5555
# stop adbd
# start adbd

# cd /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

# VBoxManage createvm --name android-x86_64-6.0-rc1-0 --ostype Linux_64 --register
# VBoxManage modifyvm android-x86_64-6.0-rc1-0 --memory 1024 --vram 128 --usb off --audio pulse --audiocontroller sb16 --acpi on --rtcuseutc off --boot1 disk --boot2 dvd --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0
# VBoxManage storagectl android-x86_64-6.0-rc1-0 --name "IDE Controller" --add ide --controller PIIX4
# VBoxManage storageattach android-x86_64-6.0-rc1-0 --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium android-x86_64-6.0-rc1-0.vdi
# VBoxManage startvm android-x86_64-6.0-rc1-0

#------------------------------------------------------------------------------------------
# So far, All is OK
#------------------------------------------------------------------------------------------
