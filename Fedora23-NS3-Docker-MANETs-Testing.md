-----------------------------------------------------------------------------------------
Please to click the icon "EDIT" to view this file.
------------------------------------------------------------------------------------------

[root@localhost ~]# systemctl start docker.service
[root@localhost ~]# docker images 
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
imunes/vroot        latest              01abbc7aab2e        2 days ago          329.1 MB
debian              jessie              bb5d89f9b6cb        9 days ago          125.1 MB
busybox             core                47bcc53f74dc        7 weeks ago         1.113 MB
busybox             latest              47bcc53f74dc        7 weeks ago         1.113 MB
<none>              <none>              b371dc438151        3 months ago        329.1 MB
[root@localhost ~]# 

[root@localhost ~]# mkdir /tmp/docker1
[root@localhost ~]# mkdir /tmp/docker2

------------------------------------------------------------------------------------------
Fedora23 + Docker
------------------------------------------------------------------------------------------
[root@localhost ~]# cd /tmp/docker1
[root@localhost docker1]# docker run --rm -it busybox /bin/sh
/ # ifconfig 
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:02  
          inet addr:172.17.0.2  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe11:2/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:16 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1296 (1.2 KiB)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # ping -c 1 172.17.0.3
PING 172.17.0.3 (172.17.0.3): 56 data bytes
64 bytes from 172.17.0.3: seq=0 ttl=64 time=0.096 ms

--- 172.17.0.3 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.096/0.096/0.096 ms
/ # exit
[root@localhost docker1]# 
------------------------------------------------------------------------------------------
[root@localhost ~]# cd /tmp/docker2
[root@localhost docker2]# docker run --rm -it busybox /bin/sh
/ # ifconfig 
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:03
          inet addr:172.17.0.3  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe11:3/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:10 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:788 (788.0 B)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # ping -c 1 172.17.0.2
PING 172.17.0.2 (172.17.0.2): 56 data bytes
64 bytes from 172.17.0.2: seq=0 ttl=64 time=0.074 ms

--- 172.17.0.2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.074/0.074/0.074 ms
/ # exit
[root@localhost docker2]# 
------------------------------------------------------------------------------------------
[root@localhost ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.108.160.1    0.0.0.0         UG    100    0        0 enp13s0
10.3.9.2        10.108.160.1    255.255.255.255 UGH   100    0        0 enp13s0
10.108.160.0    0.0.0.0         255.255.252.0   U     100    0        0 enp13s0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
192.168.122.0   0.0.0.0         255.255.255.0   U     0      0        0 virbr0
[root@localhost ~]# 
------------------------------------------------------------------------------------------
[root@localhost ~]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     udp  --  anywhere             anywhere             udp dpt:domain
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:domain
ACCEPT     udp  --  anywhere             anywhere             udp dpt:bootps
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:bootps
ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
ACCEPT     all  --  anywhere             anywhere            
INPUT_direct  all  --  anywhere             anywhere            
INPUT_ZONES_SOURCE  all  --  anywhere             anywhere            
INPUT_ZONES  all  --  anywhere             anywhere            
ACCEPT     icmp --  anywhere             anywhere            
DROP       all  --  anywhere             anywhere             ctstate INVALID
REJECT     all  --  anywhere             anywhere             reject-with icmp-host-prohibited

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         
DOCKER-ISOLATION  all  --  anywhere             anywhere            
DOCKER     all  --  anywhere             anywhere            
ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  anywhere             192.168.122.0/24     ctstate RELATED,ESTABLISHED
ACCEPT     all  --  192.168.122.0/24     anywhere            
ACCEPT     all  --  anywhere             anywhere            
REJECT     all  --  anywhere             anywhere             reject-with icmp-port-unreachable
REJECT     all  --  anywhere             anywhere             reject-with icmp-port-unreachable
ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
ACCEPT     all  --  anywhere             anywhere            
FORWARD_direct  all  --  anywhere             anywhere            
FORWARD_IN_ZONES_SOURCE  all  --  anywhere             anywhere            
FORWARD_IN_ZONES  all  --  anywhere             anywhere            
FORWARD_OUT_ZONES_SOURCE  all  --  anywhere             anywhere            
FORWARD_OUT_ZONES  all  --  anywhere             anywhere            
ACCEPT     icmp --  anywhere             anywhere            
DROP       all  --  anywhere             anywhere             ctstate INVALID
REJECT     all  --  anywhere             anywhere             reject-with icmp-host-prohibited

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     udp  --  anywhere             anywhere             udp dpt:bootpc
OUTPUT_direct  all  --  anywhere             anywhere            

Chain DOCKER (1 references)
target     prot opt source               destination         

Chain DOCKER-ISOLATION (1 references)
target     prot opt source               destination         
RETURN     all  --  anywhere             anywhere            

Chain FORWARD_IN_ZONES (1 references)
target     prot opt source               destination         
FWDI_FedoraServer  all  --  anywhere             anywhere            [goto] 
FWDI_FedoraServer  all  --  anywhere             anywhere            [goto] 

Chain FORWARD_IN_ZONES_SOURCE (1 references)
target     prot opt source               destination         

Chain FORWARD_OUT_ZONES (1 references)
target     prot opt source               destination         
FWDO_FedoraServer  all  --  anywhere             anywhere            [goto] 
FWDO_FedoraServer  all  --  anywhere             anywhere            [goto] 

Chain FORWARD_OUT_ZONES_SOURCE (1 references)
target     prot opt source               destination         

Chain FORWARD_direct (1 references)
target     prot opt source               destination         

Chain FWDI_FedoraServer (2 references)
target     prot opt source               destination         
FWDI_FedoraServer_log  all  --  anywhere             anywhere            
FWDI_FedoraServer_deny  all  --  anywhere             anywhere            
FWDI_FedoraServer_allow  all  --  anywhere             anywhere            

Chain FWDI_FedoraServer_allow (1 references)
target     prot opt source               destination         

Chain FWDI_FedoraServer_deny (1 references)
target     prot opt source               destination         

Chain FWDI_FedoraServer_log (1 references)
target     prot opt source               destination         

Chain FWDO_FedoraServer (2 references)
target     prot opt source               destination         
FWDO_FedoraServer_log  all  --  anywhere             anywhere            
FWDO_FedoraServer_deny  all  --  anywhere             anywhere            
FWDO_FedoraServer_allow  all  --  anywhere             anywhere            

Chain FWDO_FedoraServer_allow (1 references)
target     prot opt source               destination         

Chain FWDO_FedoraServer_deny (1 references)
target     prot opt source               destination         

Chain FWDO_FedoraServer_log (1 references)
target     prot opt source               destination         

Chain INPUT_ZONES (1 references)
target     prot opt source               destination         
IN_FedoraServer  all  --  anywhere             anywhere            [goto] 
IN_FedoraServer  all  --  anywhere             anywhere            [goto] 

Chain INPUT_ZONES_SOURCE (1 references)
target     prot opt source               destination         

Chain INPUT_direct (1 references)
target     prot opt source               destination         

Chain IN_FedoraServer (2 references)
target     prot opt source               destination         
IN_FedoraServer_log  all  --  anywhere             anywhere            
IN_FedoraServer_deny  all  --  anywhere             anywhere            
IN_FedoraServer_allow  all  --  anywhere             anywhere            

Chain IN_FedoraServer_allow (1 references)
target     prot opt source               destination         
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh ctstate NEW

Chain IN_FedoraServer_deny (1 references)
target     prot opt source               destination         

Chain IN_FedoraServer_log (1 references)
target     prot opt source               destination         

Chain OUTPUT_direct (1 references)
target     prot opt source               destination         
[root@localhost ~]# 
------------------------------------------------------------------------------------------
/ # route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.17.0.1      0.0.0.0         UG    0      0        0 eth0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
/ # exit
[root@localhost docker1]# 
------------------------------------------------------------------------------------------
/ # route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.17.0.1      0.0.0.0         UG    0      0        0 eth0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
/ # exit
[root@localhost docker2]# 
------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------
Fedora23 + Docker + NS3
------------------------------------------------------------------------------------------
[root@localhost docker1]# docker run -it --rm --net='none' busybox /bin/sh
[root@localhost docker2]# docker run -it --rm --net='none' busybox /bin/sh

[root@localhost ~]# docker ps
CONTAINER ID     IMAGE      COMMAND      CREATED           STATUS          PORTS    NAMES
a90dfb953634     busybox    "/bin/sh"    36 seconds ago    Up 35 seconds            mad_bardeen
ef61724a4338     busybox    "/bin/sh"    41 seconds ago    Up 40 seconds            small_lalande

//get PID of CONTAINER
[root@localhost ~]# docker inspect -f "{{.State.Pid}}" mad_bardeen
25493
[root@localhost ~]# docker inspect -f "{{.State.Pid}}" small_lalande
25454
[root@localhost ~]# 

[root@localhost ~]# man ip-netns
       By convention a named network namespace is an object at /var/run/netns/NAME that can be opened. The file
       descriptor resulting from opening /var/run/netns/NAME refers to the specified network namespace. Holding that
       file descriptor open keeps the network namespace alive. The file descriptor can be used with the setns(2) sys‐
       tem call to change the network namespace associated with a task.

[root@localhost ~]# 
ln -s /proc/25493/ns/net /var/run/netns/25493
ln -s /proc/25454/ns/net /var/run/netns/25454

------------------------------------------------------------------------------------------
https://www.nsnam.org/wiki/HOWTO_Use_Linux_Containers_to_set_up_virtual_networks
http://yaxin-cn.github.io/Docker/docker-container-use-static-IP.html

[root@localhost ~]# 
brctl addbr br-left
brctl addbr br-right

tunctl -t tap-left
tunctl -t tap-right

ifconfig tap-left 0.0.0.0 promisc up
ifconfig tap-right 0.0.0.0 promisc up

ip link add veth_0dfb953634 type veth peer name X
brctl addif br-left veth_0dfb953634
ip link set veth_0dfb953634 up
ip link set X netns 25493

ip link add veth_61724a4338 type veth peer name Y
brctl addif br-right veth_61724a4338
ip link set veth_61724a4338 up
ip link set Y netns 25454

------------------------------------------------------------------------------------------
[root@localhost docker2]# docker run -it --rm --net='none' busybox /bin/sh
/ # ifconfig -a
X         Link encap:Ethernet  HWaddr E6:64:96:C9:F5:DF  
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
[root@localhost docker1]# docker run -it --rm --net='none' busybox /bin/sh
/ # ifconfig -a
Y         Link encap:Ethernet  HWaddr BE:32:10:48:A6:EE  
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
[root@localhost ~]# 

brctl addif br-left tap-left
ifconfig br-left up
brctl addif br-right tap-right
ifconfig br-right up

[root@localhost ~]# brctl show
bridge name    bridge id                STP enabled    interfaces
br-left        8000.5ea947f3ed2c        no             tap-left
                                                       veth_0dfb953634
br-right       8000.16168007f70a        no             tap-right
                                                       veth_61724a4338
docker0        8000.0242e1664909        no		
virbr0         8000.525400b558ab        yes            virbr0-nic


ip netns exec 25493 ip link set dev X name eth0
ip netns exec 25493 ip link set eth0 up
ip netns exec 25493 ip addr add 172.17.0.1/16 dev eth0
//ip netns exec 25493 ip route add default via 172.17.42.1

ip netns exec 25454 ip link set dev Y name eth0
ip netns exec 25454 ip link set eth0 up
ip netns exec 25454 ip addr add 172.17.0.2/16 dev eth0
//ip netns exec 25454 ip route add default via 172.17.42.1

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

------------------------------------------------------------------------------------------
[root@localhost ns-3.25]# pwd
/opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25
[root@localhost ns-3.25]# 

// ./waf clean
// ./waf configure --enable-examples --enable-tests
// ./waf clean
// ./waf configure --build-profile=optimized --enable-examples --enable-tests
// ./waf clean
// ./waf configure --build-profile=debug --enable-examples --enable-tests 	//use this command
// ./waf 	//build the debug versions of the ns-3 programs, will take a long time

./waf --run tap-csma-virtual-machine
./waf --run tap-wifi-virtual-machine

------------------------------------------------------------------------------------------
172.17.0.2 can ping 172.17.0.1 successfully
------------------------------------------------------------------------------------------
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
ifconfig br-left down
ifconfig br-right down
brctl delif br-left tap-left
brctl delif br-right tap-right
brctl delbr br-left
brctl delbr br-right

ifconfig tap-left down
ifconfig tap-right down
tunctl -d tap-left
tunctl -d tap-right
------------------------------------------------------------------------------------------
So far, OK
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
Fedora23 + Docker + NS3 + MANETs - preparing
------------------------------------------------------------------------------------------
[root@localhost ns-3.25]# pwd
/opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25
[root@localhost ns-3.25]# 

cp examples/tutorial/first.cc scratch/myfirst.cc
./waf 	//Now build your first example script using waf
./waf --run scratch/myfirst
./waf --run scratch/myfirst --vis

cp examples/wireless/wifi-adhoc.cc scratch/wifi-adhoc.cc
./waf 	//Now build your first example script using waf
./waf --run scratch/wifi-adhoc

// Examples are found under src/netanim/examples Example:
./waf --run "dumbbell-animation"            generate dumbbell-animation.xml
./NetAnim        to open dumbbell-animation.xml (/opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25)
./waf --run "wireless-animation"
./waf --run "wireless-animation --help"

cp examples/routing/manet-routing-compare.cc scratch/
./waf --run scratch/manet-routing-compare
./waf --run scratch/manet-routing-compare --vis

------------------------------------------------------
cp manet-2015.cc /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25/scratch/
./waf --run scratch/manet-2015 --vis
./waf --run scratch/manet-2015-org --vis
------------------------------------------------------

tcpdump -nn -tt -r MANET-7-0.pcap
wireshark MANET-6-0.pcap

rm *.tr *.pcap *.xml

------------------------------------------------------------------------------------------
Fedora23 + Docker + NS3 + MANETs - testing
------------------------------------------------------------------------------------------

[root@localhost ~]# mkdir /tmp/docker1; mkdir /tmp/docker2

systemctl start docker.service

[root@localhost docker1]# docker run -it --rm --net='none' busybox /bin/sh
[root@localhost docker2]# docker run -it --rm --net='none' busybox /bin/sh

[root@localhost ~]# docker ps
CONTAINER ID     IMAGE      COMMAND      CREATED           STATUS          PORTS    NAMES
70e8633bf467     busybox    "/bin/sh"    36 seconds ago    Up 35 seconds            lonely_sinoussi
1a6835b58963     busybox    "/bin/sh"    41 seconds ago    Up 40 seconds            kickass_carson

//get PID of CONTAINER
[root@localhost ~]# docker inspect -f "{{.State.Pid}}" lonely_sinoussi
17342
[root@localhost ~]# docker inspect -f "{{.State.Pid}}" kickass_carson
17303
[root@localhost ~]# 

[root@localhost ~]# man ip-netns
       By convention a named network namespace is an object at /var/run/netns/NAME that can be opened. The file
       descriptor resulting from opening /var/run/netns/NAME refers to the specified network namespace. Holding that
       file descriptor open keeps the network namespace alive. The file descriptor can be used with the setns(2) sys‐
       tem call to change the network namespace associated with a task.

[root@localhost ~]# 
ln -s /proc/17342/ns/net /var/run/netns/17342
ln -s /proc/17303/ns/net /var/run/netns/17303

------------------------------------------------------------------------------------------
https://www.nsnam.org/wiki/HOWTO_Use_Linux_Containers_to_set_up_virtual_networks
http://yaxin-cn.github.io/Docker/docker-container-use-static-IP.html

[root@localhost ~]# 
brctl addbr br-left
brctl addbr br-right

tunctl -t tap-left
tunctl -t tap-right

ifconfig tap-left 0.0.0.0 promisc up
ifconfig tap-right 0.0.0.0 promisc up

ip link add veth_e8633bf467 type veth peer name X
brctl addif br-left veth_e8633bf467
ip link set veth_e8633bf467 up
ip link set X netns 17342

ip link add veth_6835b58963 type veth peer name Y
brctl addif br-right veth_6835b58963
ip link set veth_6835b58963 up
ip link set Y netns 17303

------------------------------------------------------------------------------------------
[root@localhost docker2]# docker run -it --rm --net='none' busybox /bin/sh
/ # ifconfig -a
X         Link encap:Ethernet  HWaddr E6:64:96:C9:F5:DF  
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
[root@localhost docker1]# docker run -it --rm --net='none' busybox /bin/sh
/ # ifconfig -a
Y         Link encap:Ethernet  HWaddr BE:32:10:48:A6:EE  
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
[root@localhost ~]# 

brctl addif br-left tap-left
ifconfig br-left up
brctl addif br-right tap-right
ifconfig br-right up

[root@localhost ~]# brctl show
bridge name    bridge id                STP enabled    interfaces
br-left        8000.5ea947f3ed2c        no             tap-left
                                                       veth_e8633bf467
br-right       8000.16168007f70a        no             tap-right
                                                       veth_6835b58963
docker0        8000.0242e1664909        no		
virbr0         8000.525400b558ab        yes            virbr0-nic


ip netns exec 17342 ip link set dev X name eth0
ip netns exec 17342 ip link set eth0 up
ip netns exec 17342 ip addr add 172.17.0.1/16 dev eth0
//ip netns exec 17342 ip route add default via 172.17.42.1

ip netns exec 17303 ip link set dev Y name eth0
ip netns exec 17303 ip link set eth0 up
ip netns exec 17303 ip addr add 172.17.0.2/16 dev eth0
//ip netns exec 17303 ip route add default via 172.17.42.1

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
ifconfig br-left down
ifconfig br-right down
brctl delif br-left tap-left
brctl delif br-right tap-right
brctl delbr br-left
brctl delbr br-right

ifconfig tap-left down
ifconfig tap-right down
tunctl -d tap-left
tunctl -d tap-right

------------------------------------------------------------------------------------------
So far, OK OK OK
------------------------------------------------------------------------------------------

