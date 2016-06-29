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
#------------------------------------------------------------------------------------------





#------------------------------------------------------------------------------------------
# create_init() 
# create init_in_android-x86_64.sh
# receive one parameters
#------------------------------------------------------------------------------------------
create_init(){

	eth0_br_ip="112.26.2.$1"

	echo -e "#!/system/bin/sh\n" > init_in_android-x86_64.sh
	echo "ifconfig eth0 down" >> init_in_android-x86_64.sh
	echo "ifconfig eth0 ${eth0_br_ip} netmask 255.255.0.0 up" >> init_in_android-x86_64.sh

	echo "mount -o remount,rw /system" >> init_in_android-x86_64.sh
	echo "mount -o remount,rw /" >> init_in_android-x86_64.sh

	echo "mkdir -p /opt/android-on-linux/quagga/out/etc" >> init_in_android-x86_64.sh
	echo "cp /system/xbin/quagga/etc/zebra.conf /opt/android-on-linux/quagga/out/etc/" >> init_in_android-x86_64.sh
	echo "cp /system/xbin/quagga/etc/ospf6d.conf /opt/android-on-linux/quagga/out/etc/" >> init_in_android-x86_64.sh

	echo "/system/xbin/quagga/zebra -d" >> init_in_android-x86_64.sh
	echo "/system/xbin/quagga/ospf6d -d" >> init_in_android-x86_64.sh
}
#------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------
# create_vm() 
# receive three parameter
# num1=$1, the begin number of VM to be created
# num2=$2, the end number of VM to be created
# path=$3, the folder which includes the file android-x86_64-6.0-rc1-0.vdi

# NOTE: in android-x86_64-6.0-rc1-0.vdi,
# execute "sed -i '459a init_in_android-x86_64.sh' /system/etc/init.sh"
# copy quagga to /system/xbin/quagga, refer to http://blog.csdn.net/ztguang/article/details/51768680
#------------------------------------------------------------------------------------------
create_vm(){
	num1=$1
	num2=$2
	path=$3

	echo "enter $path"
	cd $path

	for((id=$1; id<=$2; id++))
	do

		echo "create init_in_android-x86_64.sh"
		create_init $id

		vm_name=android-x86_64-6.0-rc1-$id.vdi
		name=android-x86_64-6.0-rc1-

		# copy android-x86_64-6.0-rc1-[1-252].vdi from android-x86_64-6.0-rc1-0.vdi
		# if [ ! -f "$vm_name" ]; then
		if [ -f "$vm_name" ]; then
			echo "$vm_name exists, remove it, then copy $vm_name from android-x86_64-6.0-rc1-0.vdi"
		fi

		echo "copying $vm_name from android-x86_64-6.0-rc1-0.vdi"
		#cp android-x86_64-6.0-rc1-0.vdi $vm_name

		kill -9 `ps aux|grep vboxnet0|grep -v grep|awk '{print $2}'` &>/dev/null

		VBoxManage createvm --name $name${id} --ostype Linux_64 --register
		VBoxManage modifyvm $name${id} --memory 1024 --vram 128 --usb off --audio pulse --audiocontroller sb16 --acpi on --rtcuseutc off --boot1 disk --boot2 dvd --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0 --nic2 none --nic3 none --nic4 none
		VBoxManage storagectl $name${id} --name "IDE Controller" --add ide --controller PIIX4
		VBoxManage internalcommands sethduuid $name${id}.vdi
		VBoxManage storageattach $name${id} --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium $name${id}.vdi

		# look at VirtualBox Gloable Setting, that is, vboxnet0: 192.168.56.1, 192.168.56.2(DHCPD), (3-254)
		host0=$[2+id]
		eth0_vn_ip="192.168.56.${host0}"

		gnome-terminal -x bash -c "VBoxManage startvm --type headless $name${id}; \
sleep 30; \
gnome-terminal -x bash -c \"adb connect ${eth0_vn_ip} && adb -s ${eth0_vn_ip}:5555 root\"; \
sleep 1; \
gnome-terminal -x bash -c \"adb connect ${eth0_vn_ip} && adb -s ${eth0_vn_ip}:5555 root\"; \
sleep 1; \
adb connect ${eth0_vn_ip}; \
echo \"adb connect ${eth0_vn_ip}\"; \
adb -s ${eth0_vn_ip}:5555 shell mount -o remount,rw /system; \
adb -s ${eth0_vn_ip}:5555 shell mount -o remount,rw /; \
adb push init_in_android-x86_64.sh /system/xbin/init_in_android-x86_64.sh; \
adb -s ${eth0_vn_ip}:5555 shell chmod 755 /system/xbin/init_in_android-x86_64.sh; \
echo \"$name${id} poweroff\"; \
sleep 1; \
adb -s ${eth0_vn_ip}:5555 shell poweroff"

	# adb -s ${eth0_vn_ip}:5555 shell sed -i '459a \ init_in_android-x86_64.sh' /system/etc/init.sh; \
	# NOTE: in android-x86_64-6.0-rc1-0.vdi, execute "sed -i '459a init_in_android-x86_64.sh' /system/etc/init.sh"

	# add cp command after the line 459 of /system/etc/init.sh in android-x86_64
	# run my script at boot time in android-x86_64

	done

	echo "exit $path"
	cd -

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

