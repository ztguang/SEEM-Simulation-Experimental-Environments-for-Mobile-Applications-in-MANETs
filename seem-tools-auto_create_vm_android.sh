#!/bin/sh

#------------------------------------------------------------------------------------------
# This init script (seem-tools-auto_create_vm_android.sh) is released under GNU GPL v2,v3
# Author: Tongguang Zhang
# Date: 2016-06-29
# 
# Note, Prerequisites for using this script:  You have already created android-x86_64 virtual machine in VirtualBox.
# Path in my notebook:
# [root@localhost virtualbox-os]# pwd
#     /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os
# [root@localhost virtualbox-os]# ls
#     android-x86_64-6.0-rc1-0.vdi
#
# Note: this script will auto create android-x86_64-6.0-rc1-[1-252].vdi from android-x86_64-6.0-rc1-0.vdi
#
# NOTE: in android-x86_64-6.0-rc1-0.vdi,
# execute "sed -i '459a init_in_android-x86_64.sh' /system/etc/init.sh"
# copy quagga to /system/xbin/quagga, refer to http://blog.csdn.net/ztguang/article/details/51768680
# that is: install_quagga-0.99.21mr2.2_on_android-x86_64_in_Fedora23.txt
#
# also can execute ./seem-tools-init-android-x86_64-6.0-rc1-0.sh to init android-x86_64-6.0-rc1-0.vdi
#
# NOTE: After copying android-x86_64-6.0-rc1-[1-252].vdi from android-x86_64-6.0-rc1-0.vdi, 
# First execution will be failed,
# Second execution will be successful, may be take a long time.
#------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------
# copy_vdi() 
# receive three parameter
# num1=$1, the begin number of VM to be created
# num2=$2, the end number of VM to be created
# path=$3, the folder which includes the file android-x86_64-6.0-rc1-0.vdi
#
# copy android-x86_64-6.0-rc1-[1-252].vdi from android-x86_64-6.0-rc1-0.vdi, this process will take a long time.
#
# can copy the files in CLI, such as:
# [root@localhost virtualbox-os]# /bin/cp android-x86_64-6.0-rc1-0.vdi android-x86_64-6.0-rc1-1.vdi; /bin/cp android-x86_64-6.0-rc1-0.vdi android-x86_64-6.0-rc1-2.vdi; /bin/cp android-x86_64-6.0-rc1-0.vdi android-x86_64-6.0-rc1-3.vdi; /bin/cp android-x86_64-6.0-rc1-0.vdi android-x86_64-6.0-rc1-4.vdi; /bin/cp android-x86_64-6.0-rc1-0.vdi android-x86_64-6.0-rc1-5.vdi
#
# [root@localhost virtualbox-os]# ll -h
# -rw-------. 1 root root 3.1G 6月  30 15:43 android-x86_64-6.0-rc1-0.vdi
# -rw-------. 1 root root 3.1G 6月  30 15:45 android-x86_64-6.0-rc1-1.vdi
# -rw-------. 1 root root 3.1G 6月  30 15:47 android-x86_64-6.0-rc1-2.vdi
# -rw-------. 1 root root 3.1G 6月  30 15:48 android-x86_64-6.0-rc1-3.vdi
# -rw-------. 1 root root 3.1G 6月  30 15:50 android-x86_64-6.0-rc1-4.vdi
# -rw-------. 1 root root 3.1G 6月  30 15:51 android-x86_64-6.0-rc1-5.vdi
#
#------------------------------------------------------------------------------------------
copy_vdi(){
	num1=$1
	num2=$2
	path=$3

	echo "enter $path"
	cd $path

	for((id=$1; id<=$2; id++))
	do

		vm_name=android-x86_64-6.0-rc1-$id.vdi
		vm_name_bac=android-x86_64-6.0-rc1-$id.vdi.bac
		name=android-x86_64-6.0-rc1-

		# copy android-x86_64-6.0-rc1-[1-252].vdi from android-x86_64-6.0-rc1-0.vdi
		# if [ ! -f "$vm_name" ]; then
		if [ -f "$vm_name" ]; then
			echo "$vm_name exists, backup it, then copy $vm_name from android-x86_64-6.0-rc1-0.vdi"
			#mv $vm_name $vm_name_bac
			rm $vm_name
		fi

		echo "copying $vm_name from android-x86_64-6.0-rc1-0.vdi"
		cp android-x86_64-6.0-rc1-0.vdi $vm_name
	done

	echo "exit $path"
	cd -

}
#------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------
# create_init() 
# create init_in_android-x86_64.sh
# receive one parameters
#------------------------------------------------------------------------------------------
create_init(){

	init_name=init_in_android-x86_64.sh.$1

	eth0_br_ip="112.26.2.$1"

	echo -e "#!/system/bin/sh\n" > $init_name

	# waiting a while, push init_in_android-x86_64.sh in create_vm(),
	# due to that init_in_android-x86_64.sh may be exist in android-x86_64-6.0-rc1-[1-252].vdi
	# if create android-x86_64-6.0-rc1-[1-252].vdi from scratch create, then can delete the following line. 
	echo "sleep 60" >> $init_name

	echo "ifconfig eth0 down" >> $init_name
	echo "ifconfig eth0 ${eth0_br_ip} netmask 255.255.0.0 up" >> $init_name

	echo "mount -o remount,rw /system" >> $init_name
	echo "mount -o remount,rw /" >> $init_name

	echo "mkdir -p /opt/android-on-linux/quagga/out/etc" >> $init_name
	echo "cp /system/xbin/quagga/etc/zebra.conf /opt/android-on-linux/quagga/out/etc/" >> $init_name
	echo "cp /system/xbin/quagga/etc/ospf6d.conf /opt/android-on-linux/quagga/out/etc/" >> $init_name

	echo "/system/xbin/quagga/sbin/zebra -d" >> $init_name
	echo "/system/xbin/quagga/sbin/ospf6d -d" >> $init_name
}
#------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------
# create_vm() 
# receive three parameter
# num1=$1, the begin number of VM to be created
# num2=$2, the end number of VM to be created
# path=$3, the folder which includes the file android-x86_64-6.0-rc1-0.vdi
#------------------------------------------------------------------------------------------
create_vm(){
	num1=$1
	num2=$2
	path=$3

	# make sure that the first vm get IP 192.168.56.3
	#kill -9 `ps aux|grep vboxnet0|grep -v grep|awk '{print $2}'` &>/dev/null

	echo "enter $path"
	cd $path

	for((id=$1; id<=$2; id++))
	do

		echo "create init_in_android-x86_64.sh"
		create_init $id

		name=android-x86_64-6.0-rc1-
		init_name=init_in_android-x86_64.sh.${id}

		# make sure that the first vm get IP 192.168.56.3 from vboxnet0_DHCP
		kill -9 `ps aux|grep vboxnet0|grep -v grep|awk '{print $2}'` &>/dev/null
		sleep 1

		VBoxManage createvm --name $name${id} --ostype Linux_64 --register
		VBoxManage modifyvm $name${id} --memory 1024 --vram 128 --usb off --audio pulse --audiocontroller sb16 --acpi on --rtcuseutc off --boot1 disk --boot2 dvd --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0 --nic2 none --nic3 none --nic4 none
		VBoxManage storagectl $name${id} --name "IDE Controller" --add ide --controller PIIX4
		VBoxManage internalcommands sethduuid $name${id}.vdi
		VBoxManage storageattach $name${id} --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium $name${id}.vdi

		# look at VirtualBox Gloable Setting, that is, vboxnet0: 192.168.56.1, 192.168.56.2(DHCPD), (3-254)
		#host0=$[2+id]
		#eth0_vn_ip="192.168.56.${host0}"

		eth0_vn_ip="192.168.56.3"

		# NOTE:
		#  Serial creation, otherwise, have problems.
		# First execution will be failed,  (may be sleep 36)
		# Second execution will be successful, may be take a long time,  (may be sleep 110)

		gnome-terminal -x bash -c "VBoxManage startvm --type headless $name${id}; \
sleep 110; \
gnome-terminal -x bash -c \"adb connect ${eth0_vn_ip} && adb -s ${eth0_vn_ip} root\"; \
sleep 1; \
gnome-terminal -x bash -c \"adb connect ${eth0_vn_ip} && adb -s ${eth0_vn_ip} root\"; \
sleep 1; \
gnome-terminal -x bash -c \"adb connect ${eth0_vn_ip} && adb -s ${eth0_vn_ip} root\"; \
sleep 1; \
adb connect ${eth0_vn_ip}; \
echo \"adb connect ${eth0_vn_ip}\"; \
adb -s ${eth0_vn_ip} shell mount -o remount,rw /system; \
adb -s ${eth0_vn_ip} shell mount -o remount,rw /; \
adb push ${init_name} /system/xbin/quagga/sbin/init_in_android-x86_64.sh; \
adb -s ${eth0_vn_ip} shell chmod 755 /system/xbin/quagga/sbin/init_in_android-x86_64.sh; \
echo OK; \
echo \"$name${id} poweroff\"; \
sleep 3"

#adb -s ${eth0_vn_ip} shell poweroff"

		# adb -s ${eth0_vn_ip}:5555 shell sed -i '459a \ init_in_android-x86_64.sh' /system/etc/init.sh; \
		# NOTE: in android-x86_64-6.0-rc1-0.vdi, 
		# execute "sed -i '459a init_in_android-x86_64.sh' /system/etc/init.sh"

		# add cp command after the line 459 of /system/etc/init.sh in android-x86_64
		# run my script at boot time in android-x86_64

		# NOTE:
		#  Serial creation, otherwise, have problems.
		# First execution will be failed,  (may be sleep 50)
		# Second execution will be successful, may be take a long time,  (may be sleep 120)
		sleep 120
		VBoxManage controlvm $name${id} poweroff
		sleep 2

		#VBoxManage modifyvm $name${id} --memory 1024 --vram 128 --usb off --audio pulse --audiocontroller sb16 --acpi on --rtcuseutc off --boot1 disk --boot2 dvd --nic1 bridged --bridgeadapter1 virbr0 --nic2 none --nic3 none --nic4 none

	done

	echo "exit $path"
	cd -
}
#------------------------------------------------------------------------------------------




#------------------------------------------------------------------------------------------
# function unregister_vm()
# Description:
# receive two parameters,
# num1=$1, the begin number of VM to be created
# num2=$2, the end number of VM to be created
#------------------------------------------------------------------------------------------

unregister_vm(){

	# $1, the begin number of VM to be created
	# $2, the end number of VM to be created

	for((id=$1; id<=$2; id++))
	do
		name=android-x86_64-6.0-rc1-$id

		VBoxManage controlvm ${name} poweroff &>/dev/null
		VBoxManage unregistervm ${name} &>/dev/null
		rm "/root/VirtualBox VMs/${name}" -rf &>/dev/null

		sleep 1
	done
}
#------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------
# usage() 
# script usage
#------------------------------------------------------------------------------------------
usage(){
	cat <<-EOU
    Usage: seem-tools-auto_create_vm_android.sh num1 num2 path
        num1, the begin number of VM to be created
        num2, the end number of VM to be created
	path, the folder which includes the file android-x86_64-6.0-rc1-0.vdi

    For example:
        [root@localhost virtualbox-os]# pwd
            /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

        [root@localhost virtualbox-os]# ls android-x86_64-6.0-rc1-0.vdi
            android-x86_64-6.0-rc1-0.vdi

        [root@localhost fedora23server-share]# ls seem-tools-auto_create_vm_android.sh
            seem-tools-auto_create_vm_android.sh

        ./seem-tools-auto_create_vm_android.sh 1 1 /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

	EOU
}
#------------------------------------------------------------------------------------------

# num1=$1, the begin number of VM to be created
# num2=$2, the end number of VM to be created
# path=$3, the folder which includes the file android-x86_64-6.0-rc1-0.vdi

if [ $# -eq 3 ]; then
	if [ ! -f "$3/android-x86_64-6.0-rc1-0.vdi" ]; then
		echo "please enter correct folder which includes the file android-x86_64-6.0-rc1-0.vdi"
		exit
	fi

	# copy android-x86_64-6.0-rc1-[1-252].vdi from android-x86_64-6.0-rc1-0.vdi
	# this process will take a long time.
	# Need to pay attention
	# copy_vdi $1 $2 $3

	unregister_vm $1 $2
	#unregister_vm $1 $2

	create_vm $1 $2 $3
else
	usage
fi

# [root@localhost fedora23server-share]# pwd
# /opt/share-vm/fedora23server-share

# it is safe to execute the following command (./seem-tools-CLI-semi-auto.sh destroy 0 1) twice.

# [root@localhost fedora23server-share]# ./seem-tools-CLI-semi-auto.sh destroy 0 1 centos-manet android-x86_64-6.0-rc1- /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

# [root@localhost fedora23server-share]# ./seem-tools-CLI-semi-auto.sh destroy 0 1 centos-manet android-x86_64-6.0-rc1- /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

# [root@localhost fedora23server-share]# ./seem-tools-auto_create_vm_android.sh 1 1 /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

# [root@localhost fedora23server-share]# ./seem-tools-CLI-semi-auto.sh destroy 0 5 centos-manet android-x86_64-6.0-rc1- /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

# [root@localhost fedora23server-share]# ./seem-tools-auto_create_vm_android.sh 1 5 /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os
