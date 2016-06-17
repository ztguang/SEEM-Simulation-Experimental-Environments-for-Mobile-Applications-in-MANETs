-----------------------------------------------------------------
Please to click the icon "EDIT" to view this file.
-----------------------------------------------------------------


brctl addbr br-android
ifconfig br-android up
-----------------------------------------------------------------

[root@localhost android-on-linux]# chmod +x genymotion-2.6.0-ubuntu15_x64.bin 
[root@localhost android-on-linux]# ll -h genymotion-2.6.0-ubuntu15_x64.bin
-rwxr-xr-x. 1 root root 41M 5月  18 22:54 genymotion-2.6.0-ubuntu15_x64.bin
[root@localhost android-on-linux]# ./genymotion-2.6.0-ubuntu15_x64.bin 
Installing for all users.

Installing to folder [/opt/genymobile/genymotion]. Are you sure [y/n] ? y


- Trying to find VirtualBox toolset .................... OK (Valid version of VirtualBox found: 5.0.20r106931)
- Extracting files ..................................... OK (Extract into: [/opt/genymobile/genymotion])
- Installing launcher icon ............................. OK

Installation done successfully.

You can now use these tools from [/opt/genymobile/genymotion]:
 - genymotion
 - genymotion-shell
 - gmtool

[root@localhost android-on-linux]# 


[root@localhost genymotion]# pwd
/opt/genymobile/genymotion
[root@localhost genymotion]# ./genymotion
./genymotion: error while loading shared libraries: libjpeg.so.8: cannot open shared object file: No such file or directory
-----------------------------------------------------------------
https://github.com/maciej-c/libjpeg8x64
wget https://codeload.github.com/maciej-c/libjpeg8x64/zip/master

[root@localhost libjpeg8-x64]# ll
总用量 1176
lrwxrwxrwx. 1 root root      16 5月  18 23:12 libjpeg.so.8 -> libjpeg.so.8.0.0
-rwxrwxr-x. 1 root root 1188344 2月  12 02:23 libjpeg.so.8.0.0
[root@localhost libjpeg8-x64]# cp -a libjpeg.so.8* /usr/lib64/
-----------------------------------------------------------------

[root@localhost genymotion]# pwd
/opt/genymobile/genymotion

[root@localhost genymotion]# ./genymotion

-----------------------------------------------------------------

[root@localhost ~]# pwd
/opt/android-on-linux/android-sdk-linux/platform-tools

[root@localhost ~]# gedit /root/.bashrc
export PATH=$PATH:/opt/android-on-linux/android-sdk-linux/platform-tools

[root@localhost ~]# adb shell
root@vbox86p:/ # netcfg

netcfg eth0 up
netcfg eth0 dhcp

-----------------------------------------------------------------


------------------------------------------------------------------------------------------
Fedora23 + genymotion (android) + Docker + NS3 + MANETs - testing
------------------------------------------------------------------------------------------

[root@localhost ~]# mkdir /tmp/docker1

systemctl start docker.service

[root@localhost docker1]# docker run -it --rm --net='none' busybox /bin/sh

[root@localhost ~]# docker ps
CONTAINER ID     IMAGE      COMMAND      CREATED           STATUS          PORTS    NAMES
ffa93ae962e3     busybox    "/bin/sh"    36 seconds ago    Up 35 seconds            awesome_shirley

//get PID of CONTAINER
[root@localhost ~]# docker inspect -f "{{.State.Pid}}" awesome_shirley
14438
[root@localhost ~]# 

----------------------------
first:
----------------------------
[root@localhost genymotion]# pwd
/opt/genymobile/genymotion
[root@localhost genymotion]# ./genymotion

----------------------------
second:
----------------------------

------------------------------------------------------------------------------------------
https://www.nsnam.org/wiki/HOWTO_Use_Linux_Containers_to_set_up_virtual_networks
http://yaxin-cn.github.io/Docker/docker-container-use-static-IP.html

[root@localhost ~]# 
brctl addbr br-android
brctl addbr br-docker

tunctl -t tap-left
tunctl -t tap-right

ifconfig tap-left 0.0.0.0 promisc up
ifconfig tap-right 0.0.0.0 promisc up

// genymotion android

ip link add veth_android44 type veth peer name X
brctl addif br-android veth_android44
ip link set veth_android44 up


----------------------------
third:
----------------------------
// Virtual Box > Settings > Network > Adapter 2 > bridge, br-android, then, to start android in genymotion window.


[root@localhost ~]# man ip-netns
       By convention a named network namespace is an object at /var/run/netns/NAME that can be opened. The file
       descriptor resulting from opening /var/run/netns/NAME refers to the specified network namespace. Holding that
       file descriptor open keeps the network namespace alive. The file descriptor can be used with the setns(2) sys‐
       tem call to change the network namespace associated with a task.

[root@localhost ~]# ps aux|grep geny
root     14807  0.4  2.6 5558944 205520 ?      Sl   11:06   0:02 /opt/genymobile/genymotion/player --vm-name Custom Phone - 5.1.0 - API 22 - 768x1280

[root@localhost ~]# mkdir /var/run/netns
[root@localhost ~]# 
rm /var/run/netns/* -f
ln -s /proc/14438/ns/net /var/run/netns/14438
ln -s /proc/14807/ns/net /var/run/netns/14807
----------------------------

ip link set X netns 14807

// docker busybox

ip link add veth_docker1 type veth peer name Y
brctl addif br-docker veth_docker1
ip link set veth_docker1 up
ip link set Y netns 14438


--------------
[root@localhost ~]# ip link add veth_docker1 type veth peer name X
RTNETLINK answers: File exists
[root@localhost ~]# 
ip link delete veth_docker1
ip link delete X

systemctl restart network-online.target 
ip addr flush dev X	// to flush the device before bringing it up
--------------

------------------------------------------------------------------------------------------
[root@localhost docker2]# docker run -it --rm --net='none' busybox /bin/sh
/ # ifconfig -a
Y         Link encap:Ethernet  HWaddr 82:A9:52:BE:D2:78  
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # 
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
[root@localhost ~]# 

brctl addif br-android tap-left
ifconfig br-android up
brctl addif br-docker tap-right
ifconfig br-docker up

[root@localhost ~]# brctl show
bridge name    bridge id                STP enabled    interfaces
br-android        8000.5ea947f3ed2c        no             tap-left
                                                       veth_android44
br-docker       8000.16168007f70a        no             tap-right
                                                       veth_docker1
docker0        8000.0242e1664909        no		
virbr0         8000.525400b558ab        yes            virbr0-nic

// genymotion android

ip netns exec 14807 ip link set dev X name eth1
ip netns exec 14807 ip link set eth1 up
ip netns exec 14807 ip addr add 172.17.0.2/16 dev eth1
//ip netns exec 14807 ip route add default via 172.17.42.1

// docker busybox

ip netns exec 14438 ip link set dev Y name eth0
ip netns exec 14438 ip link set eth0 up
ip netns exec 14438 ip addr add 172.17.0.1/16 dev eth0
//ip netns exec 14438 ip route add default via 172.17.42.1


------------------------------------------------------------------------------------------
/ # route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
/ # 
------------------------------------------------------------------------------------------
//You will also have to make sure that your kernel has ethernet filtering (ebtables, bridge-nf, arptables) disabled. If you do not do this, only STP and ARP traffic will be allowed to flow across your bridge and your whole scenario will not work.

[root@localhost ~]# 

cd /proc/sys/net/bridge
for f in bridge-nf-*; do echo 0 > $f; done
cd -
------------------------------------------------------------------------------------------
172.17.0.2 can not ping 172.17.0.1
------------------------------------------------------------------------------------------
/ # ping 172.17.0.1
PING 172.17.0.1 (172.17.0.1): 56 data bytes
^C
--- 172.17.0.1 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss

------------------------------------------------------
cp manet-2015.cc /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25/scratch/

[root@localhost ns-3.25]# pwd
/opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25
[root@localhost ns-3.25]# 

./waf --run scratch/manet-2015 --vis
------------------------------------------------------

172.17.0.2 can ping 172.17.0.1 successfully

------------------------------------------------------
/ # ping 172.17.0.1
PING 172.17.0.1 (172.17.0.1): 56 data bytes
64 bytes from 172.17.0.1: seq=0 ttl=64 time=0.619 ms
64 bytes from 172.17.0.1: seq=1 ttl=64 time=0.363 ms
^C
--- 172.17.0.1 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.363/0.491/0.619 ms
/ # 
------------------------------------------------------------------------------------------
ifconfig br-android down
ifconfig br-docker down
brctl delif br-android tap-left
brctl delif br-docker tap-right
brctl delbr br-android
brctl delbr br-docker

ifconfig tap-left down
ifconfig tap-right down
tunctl -d tap-left
tunctl -d tap-right

ip link delete veth_android44
ip link delete X
ip link delete veth_docker1
ip link delete Y

ip link delete eth1

------------------------------------------------------------------------------------------
So far, OK OK OK
------------------------------------------------------------------------------------------


