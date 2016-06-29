#!/bin/sh

#------------------------------------------------------------------------------------------
# This init script (auto_create_vm_android-x86_64.sh) is released under GNU GPL v2,v3
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
# Note: this script will auto create android-x86_64-6.0-rc1-[1-n].vdi from android-x86_64-6.0-rc1-0.vdi
#------------------------------------------------------------------------------------------





#------------------------------------------------------------------------------------------
# create_init() 
# create init_in_android-x86_64.sh
# receive one parameters
#------------------------------------------------------------------------------------------
create_init(){

	eth0_br_ip="192.168.26.$1"

	echo "#!/system/bin/sh\n" > init_in_android-x86_64.sh
	echo "ifconfig eth0 down" >> init_in_android-x86_64.sh
	echo "ifconfig eth0 ${eth0_br_ip} netmask 255.255.255.0 up" >> init_in_android-x86_64.sh

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
# receive one parameter, the number of VM to be created
#------------------------------------------------------------------------------------------
create_vm(){

	# num=$1, the number of VM to be created
	# path=$2, the folder which includes the file android-x86_64-6.0-rc1-0.vdi
	num=$1
	path=$2

	echo "enter $path"
	cd $path

	for((id=1; id<=$num; id++))
	do

		echo "create init_in_android-x86_64.sh"
		create_init $id

		vm_name=android-x86_64-6.0-rc1-$id.vdi
		name=android-x86_64-6.0-rc1-

		# copy android-x86_64-6.0-rc1-[1-n].vdi from android-x86_64-6.0-rc1-0.vdi
		if [ ! -f "$vm_name" ]; then
			echo "$vm_name exists, remove it, then copy $vm_name from android-x86_64-6.0-rc1-0.vdi"
			cp android-x86_64-6.0-rc1-0.vdi $vm_name
		fi

		VBoxManage createvm --name $name${id} --ostype Linux_64 --register
		VBoxManage modifyvm $name${id} --memory 1024 --vram 128 --usb off --audio pulse --audiocontroller sb16 --acpi on --rtcuseutc off --boot1 disk --boot2 dvd --nic1 hostonly --nictype1 Am79C973 --hostonlyadapter1 vboxnet0 --nic2 none --nic3 none --nic4 none
		VBoxManage storagectl $name${id} --name \"IDE Controller\" --add ide --controller PIIX4
		VBoxManage storageattach $name${id} --storagectl \"IDE Controller\" --port 0 --device 0 --type hdd --medium $4/$name${id}.vdi

		# look at VirtualBox Gloable Setting, that is, vboxnet0: 192.168.56.1, 192.168.56.2(DHCPD), (3-254)
		host0=$[2+id]
		eth0_vn_ip="192.168.56.${host0}"

		gnome-terminal -x bash -c "VBoxManage startvm --type headless $name${id}; \
sleep 30; \
adb connect ${eth0_vn_ip}; \
sleep 1; \
adb -s ${eth0_vn_ip}:5555 root; \
sleep 1; \
adb connect ${eth0_vn_ip}; \
sleep 1; \
adb -s ${eth0_vn_ip}:5555 root; \
sleep 1; \
adb connect ${eth0_vn_ip}; \
adb -s ${eth0_vn_ip}:5555 shell mount -o remount,rw /system; \
adb -s ${eth0_vn_ip}:5555 shell mount -o remount,rw /; \
adb push init_in_android-x86_64.sh /system/xbin/init_in_android-x86_64.sh; \
adb -s ${eth0_vn_ip}:5555 shell chmod 755 /system/xbin/init_in_android-x86_64.sh; \
adb -s ${eth0_vn_ip}:5555 shell sed -i '459a \ /system/xbin/init_in_android-x86_64.sh' /system/etc/init.sh; \
adb -s ${eth0_vn_ip}:5555 shell poweroff"

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
    Usage: auto_create_vm_android-x86_64.sh num path
        num, the number of VM to be created
	path, the folder which includes the file android-x86_64-6.0-rc1-0.vdi

    For example:
        [root@localhost virtualbox-os]# pwd
            /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

        [root@localhost virtualbox-os]# ls android-x86_64-6.0-rc1-0.vdi
            android-x86_64-6.0-rc1-0.vdi

        [root@localhost fedora23server-share]# ls auto_create_vm_android-x86_64.sh
            auto_create_vm_android-x86_64.sh

        ./auto_create_vm_android-x86_64.sh 5 /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

	EOU
}
#------------------------------------------------------------------------------------------

# num=$1, the number of VM to be created
# path=$2, the folder which includes the file android-x86_64-6.0-rc1-0.vdi

if [ $# -eq 2 ]; then
	if [ ! -f "$2/android-x86_64-6.0-rc1-0.vdi" ]; then
		echo "please enter correct folder which includes the file android-x86_64-6.0-rc1-0.vdi"
		exit
	fi

	create_vm $1 $2
else
	usage
fi


