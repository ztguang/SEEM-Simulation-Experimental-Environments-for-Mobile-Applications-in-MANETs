#!/bin/sh

#------------------------------------------------------------------------------------------
# This tool (seem-tools-CLI-semi-auto.sh) is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2016-06-18
# 
# Note, Prerequisites for using this script:  You have already installed Docker and NS3.
# Path in my notebook:
# NS3: /opt/tools/network_simulators/ns3/ns-allinone-3.25/
#------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------
# (OK)(OK)(All in CLI) Fedora23 + Docker(busybox) + NS3 + MANETs - testing
#------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------
# function create_docker()
# Description:
# create $docker_node_num of dockers
#------------------------------------------------------------------------------------------

create_docker(){	

	# You will also have to make sure that your kernel has ethernet filtering (ebtables, bridge-nf,
	# arptables) disabled. If you do not do this, only STP and ARP traffic will be allowed to 
	# flow across your bridge and your whole scenario will not work.
	cd /proc/sys/net/bridge
	for f in bridge-nf-*; do echo 0 > $f; done
	cd -

	# [root@localhost ~]# man ip-netns
	# By convention a named network namespace is an object at /var/run/netns/NAME that can be opened.
	# The file descriptor resulting from opening /var/run/netns/NAME refers to the specified network
	# namespace. Holding that file descriptor open keeps the network namespace alive.
	# The file descriptor can be used with the setns(2) system
	# call to change the network namespace associated with a task.

	mkdir -p /var/run/netns 2>/dev/null

	# $2, that is, $docker_node_num
	for((id=1; id<=$2; id++))
	do

		docker run -it --rm --net='none' --name "docker_${id}" busybox /bin/sh

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
		ip link set ${deth} netns ${pid}

		tunctl -t ${tap}
		ifconfig ${tap} 0.0.0.0 promisc up

		brctl addif ${bridge} ${tap}
		ifconfig ${bridge} up

		ln -s /proc/${pid}/ns/net /var/run/netns/${pid}

		ip netns exec ${pid} ip link set dev ${deth} name eth0
		ip netns exec ${pid} ip link set eth0 up
		ip netns exec ${pid} ip addr add 192.168.1.${id}/24 dev eth0
	done

}

#------------------------------------------------------------------------------------------
# function destroy_docker()
# Description:
# destroy $docker_node_num of dockers
#------------------------------------------------------------------------------------------

destroy_docker(){

	# $2, that is, $docker_node_num
	for((id=1; id<=$2; id++))
	do
		bridge="br_d_${id}"
		tap="tap_d_${id}"

		ifconfig ${bridge} down
		brctl delif ${bridge} ${tap}
		brctl delbr ${bridge}

		ifconfig ${tap} down
		tunctl -d ${tap}
	done
}


#------------------------------------------------------------------------------------------
# So far, OK OK OK
#------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------
# (OK)(OK)(All in CLI) running two Android-x86 which connect to NS3(MANETs) via "ethernet bridge"
#--------------------------------------------------------------------------
# ip route add 192.168.1.0/24 dev br_a_1
# adb devices
# adb root
# adb -s 192.168.56.101:5555 shell
# VBoxManage controlvm android-x86-6.0-rc1-1 poweroff

#------------------------------------------------------------------------------------------
# function create_android()
# Description:
# create $android_node_num of dockers
#------------------------------------------------------------------------------------------

create_android(){	

	# $3, that is, $android_node_num
	# $2, that is, $docker_node_num
	host1=$2+1

	for((host1=$2, id=1; id<=$3; host1++, id++))
	do
		# SET VARIABLES
		bridge="br_a_${id}"
		tap="tap_a_${id}"

		host0=100+${id}
		eth0_a_ip="192.168.56.${host0}"
		eth1_a_ip="192.168.1.${host1}"

		tunctl -t ${tap}
		ip link set up dev ${tap}
		brctl addbr ${bridge}
		brctl addif ${bridge} ${tap}
		ip link set up dev ${bridge}
		ifconfig ${bridge} up

		VBoxManage modifyvm android-x86-6.0-rc1-${id} --memory 1024 --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0  --nic2 bridged --bridgeadapter2 ${bridge}
		VBoxManage startvm android-x86-6.0-rc1-${id}
		sleep 30
		adb connect ${eth0_a_ip}
		sleep 1
		adb -s ${eth0_a_ip}:5555 root
		sleep 1
		adb connect ${eth0_a_ip}
		sleep 1
		adb -s ${eth0_a_ip}:5555 root
		sleep 1
		adb connect ${eth0_a_ip}
		adb -s ${eth0_a_ip}:5555 shell ifconfig eth1 down
		adb -s ${eth0_a_ip}:5555 shell ifconfig eth1 ${eth1_a_ip} netmask 255.255.255.0 up
		adb -s ${eth0_a_ip}:5555 shell ifconfig eth0 down

	done

}


#------------------------------------------------------------------------------------------
# function destroy_android()
# Description:
# destroy $android_node_num of androids
#------------------------------------------------------------------------------------------

destroy_android(){

	# $3, that is, $android_node_num
	for((id=1; id<=$3; id++))
	do
		VBoxManage controlvm android-x86-6.0-rc1-${id} poweroff
		sleep 1

		bridge="br_a_${id}"
		tap="tap_a_${id}"

		ifconfig ${bridge} down
		brctl delif ${bridge} ${tap}
		brctl delbr ${bridge}

		ifconfig ${tap} down
		tunctl -d ${tap}
	done
}


#------------------------------------------------------------------------------------------
# usage() 
# script usage
#------------------------------------------------------------------------------------------
usage(){
	cat <<-EOU
    Usage: seem-tools-CLI-semi-auto.sh a b c
        a, the value is create or destroy
        b, the number of dockers to be created
        c, the number of androids to be created

        Note: b + c <= 254

    For example:
        seem-tools-CLI-semi-auto.sh create 10 0
        seem-tools-CLI-semi-auto.sh create 0 10
        seem-tools-CLI-semi-auto.sh create 10 5
        seem-tools-CLI-semi-auto.sh destroy
	EOU
}


#------------------------------------------------------------------------------------------
# function create_ns3_manet_seem_cc()
#------------------------------------------------------------------------------------------

create_ns3_manet_seem_cc(){
	echo "create manet-seem.cc from manet-seem-template.cc"

	cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25/scratch
	rm manet-seem.cc -f 2>/dev/null
	cp manet-seem-template.cc manet-seem.cc

	str='266a \\n  '

	for((id=1; id<=$2; id++))
	do
		tap="tap_a_${id}"
		inter="tapBridge.SetAttribute (\"DeviceName\", StringValue (\"${tap}\"));\n  tapBridge.Install (nodes.Get (${id}), devices.Get (${id}));\n  "
		str=${str}${inter}
	done

	for((id=$2+1; id<=$2+$3; id++))
	do
		tap="tap_a_${id}"

		# sed -i '266a \\n  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_1"));\n  tapBridge.Install (nodes.Get (0), devices.Get (0));\n  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_2"));\n  tapBridge.Install (nodes.Get (0), devices.Get (0));' manet-seem.cc

		inter="tapBridge.SetAttribute (\"DeviceName\", StringValue (\"${tap}\"));\n  tapBridge.Install (nodes.Get (${id}), devices.Get (${id}));\n  "
		str=${str}${inter}
	done

	sed -i "${str}" manet-seem.cc

	cd -
}


#------------------------------------------------------------------------------------------
# function start_ns3()
#------------------------------------------------------------------------------------------

start_ns3(){
	echo "RUNNING SIMULATION, press CTRL-C to stop it"

	cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25

	./waf --run scratch/manet-seem --vis

	cd -
}


#------------------------------------------------------------------------------------------
# seem-tools-CLI-semi-auto.sh $operate $docker_node_num $android_node_num
# $1, that is, $operate, the value is create or destroy
# $2, that is, $docker_node_num, the number of dockers to be created
# $3, that is, $android_node_num, the number of androids to be created
#
# seem-tools-CLI-semi-auto.sh create 10 0
# seem-tools-CLI-semi-auto.sh create 0 10
# seem-tools-CLI-semi-auto.sh create 10 5
# seem-tools-CLI-semi-auto.sh destroy
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

if [ $# -eq 3 ]; then

	if [ $[a+b] -gt 254 ] || [ $2 -lt 0 ] || [ $3 -lt 0 ] || !([ $1 == "create" ]||[ $1 == "destroy" ]); then
		usage
		exit
	fi

	case $1 in
		create)
			if [ $2 -gt 0 ]; then create_docker; fi
			if [ $3 -gt 0 ]; then create_android; fi
			if [ $[a+b] -gt 0 ]; then
				create_ns3_manet_seem_cc
				start_ns3
			fi
		;;
		destroy)
			if [ $2 -gt 0 ]; then
				destroy_docker
				rm /var/run/netns -rf 2>/dev/null
			fi

			if [ $3 -gt 0 ]; then
				destroy_android
				ifconfig vboxnet0 down 2>/dev/null
			fi
		;;
	esac
else
	usage
fi

#------------------------------------------------------------------------------------------
# So far, All is OK
#------------------------------------------------------------------------------------------

