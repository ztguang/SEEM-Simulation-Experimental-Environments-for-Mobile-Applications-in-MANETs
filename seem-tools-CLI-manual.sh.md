-----------------------------------------------------------------
Please download this file and view it by gedit.
-----------------------------------------------------------------


#------------------------------------------------------------------------------------------
# (OK)(OK)(All in CLI) Fedora23 + Docker(busybox) + NS3 + MANETs - testing
#------------------------------------------------------------------------------------------

systemctl start docker.service

# docker search image_name
# docker pull image_name
# docker images
# docker rmi image_name
# docker run --privileged -i -t -d --net=none --name docker-$id $docker_image -t $type -i $id
# docker ps
docker run -it --rm --net='none' --name docker-1 busybox /bin/sh
docker run -it --rm --net='none' --name docker-2 busybox /bin/sh

# get PID of CONTAINER
[root@localhost ~]# docker inspect -f "{{.State.Pid}}" docker-1
31321
[root@localhost ~]# docker inspect -f "{{.State.Pid}}" docker-2
31357

# [root@localhost ~]# man ip-netns
#       By convention a named network namespace is an object at /var/run/netns/NAME that can be opened. The file
#       descriptor resulting from opening /var/run/netns/NAME refers to the specified network namespace. Holding that
#       file descriptor open keeps the network namespace alive. The file descriptor can be used with the setns(2) sys‐
#       tem call to change the network namespace associated with a task.

#------------------------------------------------------------------------------------------
# https://www.nsnam.org/wiki/HOWTO_Use_Linux_Containers_to_set_up_virtual_networks
# http://yaxin-cn.github.io/Docker/docker-container-use-static-IP.html

#[root@localhost ~]# 

brctl addbr br_d_1
brctl addbr br_d_2

ip link add veth_1 type veth peer name X
brctl addif br_d_1 veth_1
ip link set veth_1 up
ip link set X netns 31321

ip link add veth_2 type veth peer name Y
brctl addif br_d_2 veth_2
ip link set veth_2 up
ip link set Y netns 31357

tunctl -t tap_d_1
tunctl -t tap_d_2
ifconfig tap_d_1 0.0.0.0 promisc up
ifconfig tap_d_2 0.0.0.0 promisc up

brctl addif br_d_1 tap_d_1
ifconfig br_d_1 up
brctl addif br_d_2 tap_d_2
ifconfig br_d_2 up

mkdir /var/run/netns
ln -s /proc/31321/ns/net /var/run/netns/31321
ln -s /proc/31357/ns/net /var/run/netns/31357

ip netns exec 31321 ip link set dev X name eth0
ip netns exec 31321 ip link set eth0 up
ip netns exec 31321 ip addr add 172.17.0.1/16 dev eth0

ip netns exec 31357 ip link set dev Y name eth0
ip netns exec 31357 ip link set eth0 up
ip netns exec 31357 ip addr add 172.17.0.2/16 dev eth0

cd /proc/sys/net/bridge
for f in bridge-nf-*; do echo 0 > $f; done
cd -

# ip netns exec 31321 ip route add default via 172.17.42.1
# ip netns exec 31357 ip route add default via 172.17.42.1
# [root@localhost ~]# brctl show
# / # route -n
# You will also have to make sure that your kernel has ethernet filtering (ebtables, bridge-nf, arptables) disabled. If you do not do this, only STP and ARP traffic will be allowed to flow across your bridge and your whole scenario will not work.


#-----------------------
# running NS3
#-----------------------
[root@localhost ~]# cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25

[root@localhost ns-3.25]# gedit scratch/manet-docker.cc 
#----------------
  TapBridgeHelper tapBridge;
  tapBridge.SetAttribute ("Mode", StringValue ("UseLocal"));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_1"));
  tapBridge.Install (nodes.Get (0), devices.Get (0));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_2"));
  tapBridge.Install (nodes.Get (1), devices.Get (1));
#----------------

[root@localhost ns-3.25]# ./waf --run scratch/manet-docker --vis

# ./waf --run tap-csma-virtual-machine
# ./waf --run tap-wifi-virtual-machine

------------------------------------------------------
172.17.0.2 can ping 172.17.0.1 successfully
------------------------------------------------------

ifconfig br_d_1 down
ifconfig br_d_2 down
brctl delif br_d_1 tap_d_1
brctl delif br_d_2 tap_d_2
brctl delbr br_d_1
brctl delbr br_d_2

ifconfig tap_d_1 down
ifconfig tap_d_2 down
tunctl -d tap_d_1
tunctl -d tap_d_2


#------------------------------------------------------------------------------------------
# So far, OK OK OK
#------------------------------------------------------------------------------------------





#--------------------------------------------------------------------------
# (OK)(OK)(All in CLI) running two Android-x86 which connect to NS3(MANETs) via "ethernet bridge"
#--------------------------------------------------------------------------

#-----------
# in HOST
#-----------
tunctl -t tap_a_1
ip link set up dev tap_a_1
brctl addbr br_a_1
brctl addif br_a_1 tap_a_1
ip link set up dev br_a_1
ip addr add 10.1.1.1/24 dev br_a_1
# ip route add 10.1.1.0/24 dev br_a_1
#-----------
tunctl -t tap_a_2
ip link set up dev tap_a_2
brctl addbr br_a_2
brctl addif br_a_2 tap_a_2
ip link set up dev br_a_2
ip addr add 10.1.1.2/24 dev br_a_2
# ip route add 10.1.1.0/24 dev br_a_2
#-----------

# adb devices
# adb root
# adb -s 192.168.56.101:5555 shell

VBoxManage modifyvm android-x86-6.0-rc1-1 --memory 1024 --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0  --nic2 bridged --bridgeadapter2 br_a_1
VBoxManage startvm android-x86-6.0-rc1-1
sleep 30
adb connect 192.168.56.101
sleep 1
adb -s 192.168.56.101:5555 root
sleep 1
adb connect 192.168.56.101
sleep 1
adb -s 192.168.56.101:5555 root
sleep 1
adb connect 192.168.56.101
adb -s 192.168.56.101:5555 shell ifconfig eth1 down
adb -s 192.168.56.101:5555 shell ifconfig eth1 10.1.1.10 netmask 255.255.255.0 up
adb -s 192.168.56.101:5555 shell ifconfig eth0 down

# VBoxManage controlvm android-x86-6.0-rc1-1 poweroff

VBoxManage modifyvm android-x86-6.0-rc1-2 --memory 1024 --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0  --nic2 bridged --bridgeadapter2 br_a_2
VBoxManage startvm android-x86-6.0-rc1-2
sleep 30
adb connect 192.168.56.102
sleep 1
adb -s 192.168.56.102:5555 root
sleep 1
adb connect 192.168.56.102
sleep 1
adb -s 192.168.56.102:5555 root
sleep 1
adb connect 192.168.56.102
adb -s 192.168.56.102:5555 shell ifconfig eth1 down
adb -s 192.168.56.102:5555 shell ifconfig eth1 10.1.1.20 netmask 255.255.255.0 up
adb -s 192.168.56.102:5555 shell ifconfig eth0 down

# VBoxManage controlvm android-x86-6.0-rc1-2 poweroff


#-----------------------
# running NS3
#-----------------------
[root@localhost ~]# cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25

[root@localhost ns-3.25]# gedit scratch/manet-docker.cc 
#----------------
  TapBridgeHelper tapBridge;
  tapBridge.SetAttribute ("Mode", StringValue ("UseLocal"));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_1"));
  tapBridge.Install (nodes.Get (0), devices.Get (0));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_2"));
  tapBridge.Install (nodes.Get (1), devices.Get (1));
#----------------

[root@localhost ns-3.25]# ./waf --run scratch/manet-docker --vis

# ./waf --run tap-csma-virtual-machine
# ./waf --run tap-wifi-virtual-machine

#-------------------
ifconfig br_a_1 down
brctl delif br_a_1 tap_a_1
brctl delbr br_a_1
ifconfig tap_a_1 down
tunctl -d tap_a_1

ifconfig br_a_2 down
brctl delif br_a_2 tap_a_2
brctl delbr br_a_2
ifconfig tap_a_2 down
tunctl -d tap_a_2

ifconfig vboxnet0 down
ifdown vboxnet0
#-------------------


#------------------------------------------------------------------------------------------
# So far, All is OK
#------------------------------------------------------------------------------------------

