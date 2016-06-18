-----------------------------------------------------------------
Please download this file and view it by gedit.
-----------------------------------------------------------------

[root@localhost android-6.0.1_r46]# cat /etc/redhat-release 
Fedora release 23 (Twenty Three)

[root@localhost android-6.0.1_r46]# uname -a
Linux localhost.localdomain 4.4.8-300.fc23.x86_64 #1 SMP Wed Apr 20 16:59:27 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

[root@localhost android-6.0.1_r46]# free -h
              total        used        free      shared  buff/cache   available
Mem:           7.5G        6.2G         54M        579M        1.2G        600M
Swap:          1.0G        1.0G          0B

[root@localhost android-6.0.1_r46]# cat /proc/cpuinfo
processor	: 3
vendor_id	: GenuineIntel
cpu family	: 6
model		: 60
model name	: Intel(R) Core(TM) i5-4200M CPU @ 2.50GHz
stepping	: 3
microcode	: 0x1e
cpu MHz		: 2153.906
cache size	: 3072 KB

+++++++++++++++++++++++++++++++++++++++++++++
download android source code
+++++++++++++++++++++++++++++++++++++++++++++
[root@localhost android-6.0.1_r46]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46
[root@localhost android-6.0.1_r46]# 

git config --global user.name "tongguang"
git config --global user.email "jsjoscpubupt@gmail.com"

repo init -u https://android.googlesource.com/platform/manifest

repo init -u https://android.googlesource.com/platform/manifest -b android-4.0.1_r1
repo init -u https://android.googlesource.com/platform/manifest -b android-5.0.0_r1
repo init -u https://android.googlesource.com/platform/manifest -b android-5.0.0_r2
repo init -u https://android.googlesource.com/platform/manifest -b android-5.0.2_r1
repo init -u https://android.googlesource.com/platform/manifest -b android-5.1.1_r37

repo init -u https://android.googlesource.com/platform/manifest -b android-6.0.1_r46

repo sync

+++++++++++++++++++++++++++++++++++++++++++++

[root@localhost gem5-stable]# free
              total        used        free      shared  buff/cache   available
Mem:        7892744     4433200      222784      520468     3236760     2807120
Swap:       1028124     1028124           0
[root@localhost gem5-stable]# free -h
              total        used        free      shared  buff/cache   available
Mem:           7.5G        4.2G        218M        508M        3.1G        2.7G
Swap:          1.0G        1.0G          0B
[root@localhost gem5-stable]# 


[root@localhost android-6.0.1_r46]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46
[root@localhost android-6.0.1_r46]# ls
Android.bp  bootstrap.bash  developers   external    libcore          out               prebuilts  tools
art         build           development  frameworks  libnativehelper  packages          sdk
bionic      cts             device       hardware    Makefile         pdk               system
bootable    dalvik          docs         kernel      ndk              platform_testing  toolchain
[root@localhost android-6.0.1_r46]# 

java -Xmx5000M -Xms1500M -XshowSettings:all 


++++++++++++++++++++++++++++++++++++++++
Establishing a Build Environment
++++++++++++++++++++++++++++++++++++++++

http://source.android.com/source/initializing.html

Put the following in your .bashrc (or equivalent):
export USE_CCACHE=1
export CCACHE_DIR=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/ccache

-----------------------
In the root of the source tree, do the following:

[root@localhost android-6.0.1_r46]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46
[root@localhost android-6.0.1_r46]# ls

export USE_CCACHE=1
export CCACHE_DIR=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/ccache
prebuilts/misc/linux-x86/ccache/ccache -M 50G

The suggested cache size is 50-100G.
On Linux, you can watch ccache being used by doing the following:

watch -n1 -d prebuilts/misc/linux-x86/ccache/ccache -s
-----------------------

++++++++++++++++++++++++++++++++++++++++
building
++++++++++++++++++++++++++++++++++++++++
The suggested cache size is 50-100GB. You will need to run the following command once you have downloaded the source code:
prebuilts/misc/linux-x86/ccache/ccache -M 50G


. build/envsetup.sh
lunch aosp_arm-userdebug
make -j4

-----------------------
can ignore
-----------------------
find: “frameworks/base/docs/html-ndk”: No file or directory 
-----------------------

++++++++++++++++++++++++++++++++++++++++
need java-1.7.0-openjdk, not java-1.8.0-openjdk
++++++++++++++++++++++++++++++++++++++++

java -version

[root@localhost gem5-stable]# ls /usr/lib/jvm/
java                                           java-openjdk       jre-1.8.0-openjdk-1.8.0.91-6.b14.fc23.x86_64
java-1.8.0                                     jre                jre-openjdk
java-1.8.0-openjdk                             jre-1.8.0
java-1.8.0-openjdk-1.8.0.91-6.b14.fc23.x86_64  jre-1.8.0-openjdk
[root@localhost gem5-stable]# 

============================================
Checking build tools versions...
************************************************************
You are attempting to build with the incorrect version
of java.
 
Your version is: openjdk version "1.8.0_91" OpenJDK Runtime Environment (build 1.8.0_91-b14) OpenJDK 64-Bit Server VM (build 25.91-b14, mixed mode).
The required version is: "1.7.x"
 
Please follow the machine setup instructions at
    https://source.android.com/source/initializing.html
************************************************************
build/core/main.mk:171: *** stop

#### make failed to build some targets (28 seconds) ####

[root@localhost android-6.0.1_r46]# 
[root@localhost android-6.0.1_r46]# export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.75-2.5.4.2.fc20.x86_64
[root@localhost android-6.0.1_r46]# export PATH=$JAVA_HOME/bin:$PATH
[root@localhost android-6.0.1_r46]# java -version
java version "1.7.0_75"
OpenJDK Runtime Environment (fedora-2.5.4.2.fc20-x86_64 u75-b13)
OpenJDK 64-Bit Server VM (build 24.75-b04, mixed mode)
[root@localhost android-6.0.1_r46]# 

*********************************************************
install java-1.7.0-openjdk
*********************************************************
http://koji.fedoraproject.org/koji/buildinfo?buildID=605625

dnf search openjdk
dnf install java-atk-wrapper

[root@localhost Desktop]# ls java-1.7.0-openjdk-*
java-1.7.0-openjdk-1.7.0.75-2.5.4.2.fc20.x86_64.rpm
java-1.7.0-openjdk-accessibility-1.7.0.75-2.5.4.2.fc20.x86_64.rpm
java-1.7.0-openjdk-debuginfo-1.7.0.75-2.5.4.2.fc20.x86_64.rpm
java-1.7.0-openjdk-demo-1.7.0.75-2.5.4.2.fc20.x86_64.rpm
java-1.7.0-openjdk-devel-1.7.0.75-2.5.4.2.fc20.x86_64.rpm
java-1.7.0-openjdk-headless-1.7.0.75-2.5.4.2.fc20.x86_64.rpm
java-1.7.0-openjdk-src-1.7.0.75-2.5.4.2.fc20.x86_64.rpm

[root@localhost Desktop]# rpm -ivh --force --nodeps java-1.7.0-openjdk-*
[root@localhost Desktop]# java -version
[root@localhost Desktop]# ls /usr/lib/jvm/

export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.75-2.5.4.2.fc20.x86_64
export PATH=$JAVA_HOME/bin:$PATH

*********************************************************
make -j4
*********************************************************
Install: out/host/linux-x86/lib64/libartd-compiler.so
java -Xmx3500m -jar out/host/linux-x86/framework/jill.jar  --output out/target/common/obj/JAVA_LIBRARIES/sdk_v8_intermediates/classes.jack.tmpjill.jack prebuilts/sdk/8/android.jar
java -Xmx3500m -jar out/host/linux-x86/framework/jill.jar  --output out/target/common/obj/JAVA_LIBRARIES/sdk_v9_intermediates/classes.jack.tmpjill.jack prebuilts/sdk/9/android.jar
java -Xmx3500m -jar out/host/linux-x86/framework/jill.jar  --output out/target/common/obj/JAVA_LIBRARIES/sdk_v4_intermediates/classes.jack.tmpjill.jack prebuilts/sdk/4/android.jar
java -Xmx3500m -jar out/host/linux-x86/framework/jill.jar  --output out/target/common/obj/JAVA_LIBRARIES/sdk_v20_intermediates/classes.jack.tmpjill.jack prebuilts/sdk/20/android.jar
java -Xmx3500m -jar out/host/linux-x86/framework/jill.jar  --output out/target/common/obj/JAVA_LIBRARIES/sdk_v19_intermediates/classes.jack.tmpjill.jack prebuilts/sdk/19/android.jar
make: fork:  cannot allocate memory 
make: *** Deleting file 'out/target/common/obj/JAVA_LIBRARIES/sdk_v20_intermediates/classes.jack'

------------------------------------------
xkill, close firefox, free memory
------------------------------------------

*********************************************************

ERROR: Bad request, see Jack server log (/tmp/jack-root/jack-8072.log)
build/core/java.mk:643: recipe for target 'out/target/common/obj/JAVA_LIBRARIES/framework_intermediates/with-local/classes.dex' failed
make: *** [out/target/common/obj/JAVA_LIBRARIES/framework_intermediates/with-local/classes.dex] Error 41
make: ***  Waiting for the unfinished task ....
DroidDoc took 26 sec. to write docs to out/target/common/docs/system-api-stubs
DroidDoc took 27 sec. to write docs to out/target/common/docs/api-stubs

#### make failed to build some targets (02:09:42 (hh:mm:ss)) ####

------------------------------------------
it is OK to exe "make -j4" again
------------------------------------------

Creating filesystem with parameters:
    Size: 1610612736
    Block size: 4096
    Blocks per group: 32768
    Inodes per group: 8192
    Inode size: 256
    Journal blocks: 6144
    Label: system
    Blocks: 393216
    Block groups: 12
    Reserved block group size: 95
Created filesystem with 1653/98304 inodes and 136658/393216 blocks
Install system fs image: out/target/product/generic/system.img
out/target/product/generic/system.img+ maxsize=1644333504 blocksize=2112 total=1610612736 reserve=16610880

#### make completed successfully (45:33 (mm:ss)) ####

[root@localhost android-6.0.1_r46]# 

#### make completed successfully (02:09:42 (hh:mm:ss)) + (45:33 (mm:ss)) = (02:55:15 (hh:mm:ss)) ####

------------------------------------------
So far, build android successfully.
------------------------------------------

*********************************************************

[root@localhost android-6.0.1_r46]# cd out/target/product/generic/
[root@localhost generic]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/out/target/product/generic

[root@localhost generic]# du -hs *
4.0K	android-info.txt
4.0K	cache
5.1M	cache.img
72K	clean_steps.mk
424K	data
66M	dex_bootjars
113M	gen
68K	installed-files.txt
10G	obj
4.0K	previous_build_config.mk
880K	ramdisk.img
708K	recovery
1.6M	root
1.7G	symbols
484M	system
1.6G	system.img
11M	userdata.img
[root@localhost generic]# ls -p
android-info.txt  clean_steps.mk  gen/                 previous_build_config.mk  root/     system.img
cache/            data/           installed-files.txt  ramdisk.img               symbols/  userdata.img
cache.img         dex_bootjars/   obj/                 recovery/                 system/

[root@localhost generic]#  emulator

emulator: WARNING: system partition size adjusted to match image file (1536 MB > 200 MB)
emulator: WARNING: data partition size adjusted to match image file (550 MB > 200 MB)
Creating filesystem with parameters:
    Size: 69206016
    Block size: 4096
    Blocks per group: 32768
    Inodes per group: 4224
    Inode size: 256
    Journal blocks: 1024
    Label: 
    Blocks: 16896
    Block groups: 1
    Reserved block group size: 7
Created filesystem with 11/4224 inodes and 1302/16896 blocks

----------
or execute the following commands.
----------
[root@localhost android-6.0.1_r46]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46
[root@localhost android-6.0.1_r46]# emulator -sysdir out/target/product/generic -system system.img

++++++++++++++++++++++++++++++++++++++++
So far, all is OK
++++++++++++++++++++++++++++++++++++++++

++++++++++++++++++++++++++++++++++++++++
example: alter the name of the application Messaging
++++++++++++++++++++++++++++++++++++++++
[root@localhost android-6.0.1_r46]# gedit packages/apps/Messaging/res/values/strings.xml 

    <!-- The name of the application as it appears under the main Launcher icon and in various activity titles -->
    <string name="app_name">Messaging-ztg</string>

[root@localhost android-6.0.1_r46]# cd packages/apps/Messaging
[root@localhost Messaging]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/packages/apps/Messaging
[root@localhost Messaging]# ls
AndroidManifest.xml  assets  ForceProguard.mk  proguard.flags          proguard-test.flags  src    tools
Android.mk           build   jni               proguard-release.flags  res                  tests  version.mk

[root@localhost Messaging]# mm
Install: out/target/product/generic/data/app/messagingtests/messagingtests.apk
make: Leaving directory '/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46'

#### make completed successfully (01:30 (mm:ss)) ####

[root@localhost Messaging]# 

[root@localhost android-6.0.1_r46]# adb shell
root@generic:/ # mount -o remount,rw /system

[root@localhost android-6.0.1_r46]# 
adb push out/target/product/generic/data/app/messagingtests/messagingtests.apk system/app/messaging/messaging.apk

++++++++++++++++++++++

[root@localhost Messaging]# cd -
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46
[root@localhost android-6.0.1_r46]# tree out/target/product/generic/system/priv-app/MmsService/
out/target/product/generic/system/priv-app/MmsService/
├── MmsService.apk
└── oat
    └── arm
        └── MmsService.odex

2 directories, 2 files

[root@localhost android-6.0.1_r46]# emulator -sysdir out/target/product/generic -system system.img

[root@localhost android-6.0.1_r46]# adb shell
root@generic:/ # mount -o remount,rw /system

root@generic:/ # df
Filesystem               Size     Used     Free   Blksize
/dev                   243.4M    68.0K   243.3M   4096
/sys/fs/cgroup         243.4M    12.0K   243.4M   4096
/mnt                   243.4M     0.0K   243.4M   4096
/system                  1.5G   509.7M  1002.2M   4096
/data                  541.3M    81.1M   460.2M   4096
/cache                  65.0M     4.1M    60.9M   4096
/storage               243.4M     0.0K   243.4M   4096

[root@localhost android-6.0.1_r46]# 
adb push out/target/product/generic/system/priv-app/MmsService/MmsService.apk system/priv-app/MmsService/
adb push out/target/product/generic/system/priv-app/MmsService/oat/arm/MmsService.odex system/priv-app/MmsService/oat/arm

[root@localhost android-6.0.1_r46]# emulator -sysdir out/target/product/generic -system system.img

++++++++++++++++++++++++++++++++++++++++
So far, example is not OK
++++++++++++++++++++++++++++++++++++++++



++++++++++++++++++++++++++++++++++++++++
gem5 + AOSP Android + NS3
++++++++++++++++++++++++++++++++++++++++

-------------
This design uses GEM5 as the computation simulator and ns-3 as the networking simulator.

Since it is designed as a full system simulator, GEM5 is typically used to boot an entire operating system image targeted for a particular architecture. The OS image contains the kernel binary which contains all the code to execute the kernel. It also contains the file system image which stores an exact copy of user space binaries as they would appear on the hard disk of a real system. In fact, this file system image can be mounted as a virtual disk partition on a Linux machine. The file system image contains the benchmarks that the user intends to evaluate in the form of native binaries. In the case of Android, the file system would include not just the Android binaries which are written in a high level byte code, but also the Dalvik runtime, which is the application level virtual machine that runs Android bytecode files.

Porting this to the ARM architecture would be beneficial to the community of mobile app developers. Further, porting Android, the dominant mobile platform to run atop this simulation infrastructure would also enhance its applicability.


-------------

http://gem5.org/Android_KitKat

[root@localhost android-6.0.1_r46]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46
[root@localhost android-6.0.1_r46]# 

. build/envsetup.sh
lunch aosp_arm-userdebug

then, can look at the following commands:
hmm 		Show a list of build system commands
mm 		Build the Android module in the current directory
mma 		Build the Android module in the current directory and its dependencies
emulator 	Launch Android in qemu 

The mm command is especially useful since just running make in a directory with an existing build of Android (i.e., make doesn't need to build anything) can take several minutes.



dd if=/dev/zero of=myimage.img bs=1M count=2048
losetup /dev/loop0 myimage.img
fdisk /dev/loop0
--------------------
Part.No Usage 	Approximate Size
1 	/ 	500MB
2 	/data 	1GB
3 	/cache 	500MB 
--------------------

partprobe /dev/loop0
mkfs.ext4 -L AndroidRoot /dev/loop0p1
mkfs.ext4 -L AndroidData /dev/loop0p2
mkfs.ext4 -L AndroidCache /dev/loop0p3

mkdir -p /mnt/android
mount /dev/loop0p1 /mnt/android
cd /mnt/android
zcat AOSP/out/target/product/generic/ramdisk.img  | cpio -i
mkdir cache

mkdir -p /mnt/tmp
mount -oro,loop AOSP/out/target/product/generic/system.img /mnt/tmp
cp -a /mnt/tmp/* system/

umount /mnt/android
losetup -d /dev/loop0


++++++++++++++++++++++++++++++++++++++++
Android —— gem5 run bench(Android) + vncviewer
++++++++++++++++++++++++++++++++++++++++
http://labrick.xyz/2015/07/15/gem5-run-bench-step/

[root@localhost my-gem5]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/

[root@localhost my-gem5]# ls
aarch-system-2014-10.tar.xz  mediaBench.zip  Mibench.tgz  my-gem5.tar.gz
[root@localhost my-gem5]# tar xzf my-gem5.tar.gz -C my-gem5

[root@localhost my-gem5]# cd my-gem5
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/my-gem5

[root@localhost my-gem5]# mkdir img
[root@localhost my-gem5]# cd ..
[root@localhost my-gem5]# tar -xJf aarch-system-2014-10.tar.xz -C my-gem5/img/
[root@localhost my-gem5]# cd my-gem5

[root@localhost my-gem5]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5
[root@localhost my-gem5]# ls
aarch-system-2014-10.tar.xz  mediaBench  mediaBench.zip  Mibench  Mibench.tgz  my-gem5  my-gem5.tar.gz
[root@localhost my-gem5]# mount -o loop,offset=32256 my-gem5/img/disks/linux-aarch32-ael.img /mnt/tmp/
[root@localhost my-gem5]# cp -a mediaBench /mnt/tmp/
[root@localhost my-gem5]# cp -a Mibench /mnt/tmp/
[root@localhost my-gem5]# cd /mnt/tmp/
[root@localhost tmp]# chmod +x mediaBench/* -R
[root@localhost tmp]# chmod +x Mibench/* -R
[root@localhost tmp]# cd -
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5
[root@localhost my-gem5]# umount /mnt/tmp/
[root@localhost my-gem5]# 

进入parsec-1目录
[root@localhost my-gem5]# cd my-gem5/parsec-1/
ln -s /opt/gem5/gem5/gem5-stable/build/ARM/gem5.opt ./
ln -s /opt/gem5/gem5/gem5-stable/configs/ ./


[root@localhost parsec-1]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/my-gem5/parsec-1
[root@localhost parsec-1]# ls -p
board_start.sh  configs/  gem5.opt  m5out/  tongji.sh
[root@localhost parsec-1]# 


[root@localhost my-gem5]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5
[root@localhost my-gem5]# ls
aarch-system-2014-10.tar.xz              linux-aarch32-ael.img  mediaBench.zip  Mibench.tgz  my-gem5.tar.gz
ARMv7a-ICS-Android.SMP.Asimbench-v3.img  mediaBench             Mibench         my-gem5      sdcard-1g-mxplayer.img


[root@localhost my-gem5]# cp sdcard-1g-mxplayer.img my-gem5/img/disks/sdcard-1g-mxplayer.img
[root@localhost my-gem5]# cp vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb my-gem5/img/binaries/vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb
[root@localhost my-gem5]# 


gedit /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/my-gem5/parsec-1/board_start.sh
#----------------
#!/bin/bash
export M5_PATH=../img/
#### android boot
./gem5.opt configs/example/fs.py --os-type=android-ics --mem-size=1024MB --kernel=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/vmlinux-gem5-android-dvfs --disk-image=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/ARMv7a-ICS-Android.SMP.Asimbench-v3.img --caches --l1i_size=32kB --l1d_size=32kB --l1d_assoc=2 --l1i_assoc=2 --l2_assoc=16 --l2cache --l2_size=128kB --num-l2caches=8 --cpu-type=AtomicSimpleCPU -n 1 --machine-type=VExpress_EMM --dtb-filename=vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb --frame-capture
#----------------


[root@localhost parsec-1]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/my-gem5/parsec-1
[root@localhost parsec-1]# ls
board_start.sh  configs  gem5.opt  m5out  tongji.sh


[root@localhost parsec-1]# ./board_start.sh 

./gem5.opt configs/example/fs.py --os-type=android-ics --mem-size=1024MB --kernel=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/vmlinux-gem5-android-dvfs --disk-image=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/ARMv7a-ICS-Android.SMP.Asimbench-v3.img --caches --l1i_size=32kB --l1d_size=32kB --l1d_assoc=2 --l1i_assoc=2 --l2_assoc=16 --l2cache --l2_size=128kB --num-l2caches=8 --cpu-type=AtomicSimpleCPU -n 1 --machine-type=VExpress_EMM --dtb-filename=vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb --frame-capture

Listening for system connection on port 5900
Listening for system connection on port 3456
0: system.remote_gdb.listener: listening for remote gdb #0 on port 7000
info: Using bootloader at address 0x10
info: Using kernel entry physical address at 0x80008000
info: Loading DTB file: ../img/binaries/vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb at address 0x88000000
**** REAL SIMULATION ****


[root@localhost gem5-stable]# pwd
/opt/gem5/gem5/gem5-stable
[root@localhost gem5-stable]# scons build/ARM/gem5.opt
--------------------------------
scons -c build/ARM/gem5.opt		//and if you want to re-build , you can make it clean using this command
--------------------------------
[root@localhost term]# pwd
/opt/gem5/gem5/gem5-stable/util/term
[root@localhost term]# make
[root@localhost gem5-stable]# ./util/term/m5term 127.0.0.1 3456


[root@localhost ~]# vncviewer -FullColour 127.0.0.1:5900



+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Android_KitKat
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--------------------------------------------
refer to http://gem5.org/Android_KitKat
--------------------------------------------
[root@localhost my-gem5]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5
[root@localhost my-gem5]# 

dd if=/dev/zero of=myimage.img bs=1M count=3572
losetup /dev/loop0 myimage.img

--------
[root@localhost my-gem5]# losetup -a
/dev/loop0: [2070]:655504 (/my-gem5/myimage.img)
[root@localhost my-gem5]# losetup -d /dev/loop0
--------

fdisk /dev/loop0

Part 	Usage 	Approximate Size
1 	/ 	2GB		AndroidRoot /dev/loop0p1	ramdisk.img(879K) + system.img(1.5G)
2 	/data 	1GB		AndroidData /dev/loop0p2	
3 	/cache 	500MB 		AndroidCache /dev/loop0p3	

[root@localhost my-gem5]# fdisk /dev/loop0
命令(输入 m 获取帮助)：p
设备         启动    起点    末尾    扇区  大小 Id 类型
/dev/loop0p1         2048 4196351 4194304    2G 83 Linux
/dev/loop0p2      4196352 6293503 2097152    1G 83 Linux
/dev/loop0p3      6293504 7315455 1021952  499M 83 Linux


partprobe /dev/loop0
mkfs.ext4 -L AndroidRoot /dev/loop0p1
mkfs.ext4 -L AndroidData /dev/loop0p2
mkfs.ext4 -L AndroidCache /dev/loop0p3

mkdir -p /mnt/android
mount /dev/loop0p1 /mnt/android
cd /mnt/android
zcat /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/out/target/product/generic/ramdisk.img  | cpio -i
mkdir cache

mkdir -p /mnt/tmp
mount -oro,loop /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/out/target/product/generic/system.img /mnt/tmp
cp -a /mnt/tmp/* system/

cd -
umount /mnt/android
losetup -d /dev/loop0



++++++++++++++++++
kernel position
++++++++++++++++++

[root@localhost parsec-1]# file /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/device/asus/flo-kernel/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/device/asus/flo-kernel/kernel: Linux kernel ARM boot executable zImage (little-endian)



[root@localhost parsec-1]# find /run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/ -name kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/bionic/libc/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/external/srtp/crypto/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/external/v8/src/third_party/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/external/jmonkeyengine/engine/src/networking/com/jme3/network/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/external/squashfs-tools/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/device/asus/flo-kernel/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/libcore/harmony-tests/src/test/java/org/apache/harmony/tests/org/apache/harmony/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/out/target/common/obj/APPS/FrameworksCoreInputMethodTests_intermediates/classes/tests/api/org/apache/harmony/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/out/target/common/obj/APPS/KeyChainTests_intermediates/classes/tests/api/org/apache/harmony/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/out/target/common/obj/APPS/mediaframeworktest_intermediates/classes/tests/api/org/apache/harmony/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/out/target/common/obj/APPS/FrameworksCoreSystemPropertiesTests_intermediates/classes/tests/api/org/apache/harmony/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/out/target/common/obj/JAVA_LIBRARIES/core-tests_intermediates/classes/tests/api/org/apache/harmony/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/system/extras/perfprofd/quipper/original-kernel-headers/tools/perf/util/include/linux/kernel
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android/android-6.0.1_r46/system/extras/perfprofd/quipper/kernel-headers/tools/perf/util/include/linux/kernel
[root@localhost parsec-1]# 

++++++++++++++++++++++++++++++++++++++++


[root@localhost parsec-1]# ./board_start.sh 

./gem5.opt configs/example/fs.py --os-type=android-ics --mem-size=1024MB --kernel=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/vmlinux-gem5-android-dvfs --disk-image=/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/my-gem5/ARMv7a-ICS-Android.SMP.Asimbench-v3.img --caches --l1i_size=32kB --l1d_size=32kB --l1d_assoc=2 --l1i_assoc=2 --l2_assoc=16 --l2cache --l2_size=128kB --num-l2caches=8 --cpu-type=AtomicSimpleCPU -n 1 --machine-type=VExpress_EMM --dtb-filename=vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb --frame-capture

Listening for system connection on port 5900
Listening for system connection on port 3456
0: system.remote_gdb.listener: listening for remote gdb #0 on port 7000
info: Using bootloader at address 0x10
info: Using kernel entry physical address at 0x80008000
info: Loading DTB file: ../img/binaries/vexpress-v2p-ca15-tc1-gem5_dvfs_1cpus.dtb at address 0x88000000
**** REAL SIMULATION ****

[root@localhost ~]# vncviewer -FullColour 127.0.0.1:5900


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Android-x86 —— compile the source code —— VirtualBox
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
http://www.android-x86.org/getsourcecode

[root@localhost android-x86-6.0-rc1]# export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.75-2.5.4.2.fc20.x86_64
[root@localhost android-x86-6.0-rc1]# export PATH=$JAVA_HOME/bin:$PATH

[root@localhost android-x86-6.0-rc1]# . build/envsetup.sh
[root@localhost android-x86-6.0-rc1]# lunch android_x86-userdebug

[root@localhost android-x86-6.0-rc1]# m -j4 iso_img
Total translation table size: 6900
Total rockridge attributes bytes: 3312
Total directory bytes: 12288
Path table size(bytes): 88
Done with: The File(s)                             Block(s)    170078
Writing:   Ending Padblock                         Start Block 170122
Done with: Ending Padblock                         Block(s)    150
Max brk space used 22000
170272 extents written (332 MB)
/bin/bash: isohybrid: 未找到命令
isohybrid not found.
Install syslinux 4.0 or higher if you want to build a usb bootable iso.

out/target/product/x86/android_x86.iso is built successfully.

make: Leaving directory '/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/android-x86/android-x86-6.0-rc1'
#### make completed successfully (03:19:54 (hh:mm:ss)) ####

------------------------------------------------------------
out/target/product/x86/android_x86.iso

[root@localhost android-x86-6.0-rc1]# ll -h out/target/product/x86/android_x86.iso
-rw-r--r--. 1 root root 333M 6月  13 18:42 out/target/product/x86/android_x86.iso
------------------------------------------------------------

------------------------------------------------------------
running Android-x86 in VirtualBox
------------------------------------------------------------
refer to http://blog.csdn.net/ztguang/article/details/51649619

-----------
in HOST
-----------
tunctl -t tap-left
ip link set up dev tap-left
brctl addbr br-android
brctl addif br-android tap-left
ip link set up dev br-android
ip addr add 10.1.1.1/24 dev br-android
ip route add 10.1.1.0/24 dev br-android
-----------
// Virtual Box > Settings > Network > Adapter 1 > bridge, br-android.

-----------
in Android
-----------
-------------------------------------
// in HOST
[root@localhost busybox]# adb push busybox-x86_64 /data
[root@localhost busybox]# adb shell

// in Android
root@vbox86p:/ # cd data/
chmod 755 busybox-x86_64
-------------------------------------
// in Android

netcfg eth1 down
./busybox-x86_64 ifconfig eth1 down
./busybox-x86_64 ifconfig eth1 10.1.1.2 netmask 255.255.255.0 up

// ./busybox-x86_64 ip addr add 10.1.1.2/24 dev eth1
// ./busybox-x86_64 ip route add default via 10.1.1.1 dev eth1

./busybox-x86_64 route -n
./busybox-x86_64 ifconfig
./busybox-x86_64 ping 10.1.1.2
-----------

-------------------------------------
ifconfig br-android down
brctl delif br-android tap-left
brctl delif br-android eth1
brctl delbr br-android
ifconfig tap-left down
tunctl -d tap-left
//ip link delete veth_android44
//ip link delete X
-------------------------------------

http://cygnus.androidapksfree.com/hulk/com.UCMobile.intl_v10.10.0.796-238_Android-2.3.apk

http://www.apkmirror.com/wp-content/uploads/uploaded/5758ac63cb322/com.android.chrome_51.0.2704.81-270408111_minAPI21(x86)(nodpi)_apkmirror.com.apk
------------------------------------------------------------


--------------------------------------------------------------------------
netcat transfer file to android from fedora23
--------------------------------------------------------------------------
Server (fedora23)
[root@localhost Desktop]# pwd
/root/Desktop
[root@localhost Desktop]# ls cm-browser5-20-38.apk 
cm-browser5-20-38.apk
[root@localhost Desktop]# 
iptables -I INPUT -p tcp --dport 12123 -j ACCEPT
iptables -D INPUT -p tcp --dport 12123 -j ACCEPT
nc -l 12123 < chrome51.apk

Client (android)
nc 10.108.162.164 12123 > chrome51.apk

Client (fedora/linux)
nc -n 10.108.162.164 12123 > chrome51.apk

--------------------------------------------------------------------------
Android 6.0 (Marshmallow) Install apk - INSTALL_FAILED_INVALID_URI 
--------------------------------------------------------------------------

must be under the root directory:

cd /
pm install /sdcard/Download/chrome51.apk

Success
-------------------------------------


--------------------------------------------------------------------------
Error when importing VDI file in VirtualBox
--------------------------------------------------------------------------

Cannot register the hard disk '/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os/Android-x86-6.0-rc1-1.vdi' {dbfc8e7b-4969-4836-86d9-418e60328b83} because a hard disk '/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os/android-x86-6.0-rc1-2.vdi' with UUID {dbfc8e7b-4969-4836-86d9-418e60328b83} already exists.

Solution：

[root@localhost virtualbox-os]# VBoxManage internalcommands sethduuid android-x86-6.0-rc1-1.vdi
UUID changed to: 865924c0-53b5-4aac-83b3-2402b33acdeb

[root@localhost virtualbox-os]# VBoxManage internalcommands dumphdinfo android-x86-6.0-rc1-1.vdi


--------------------------------------------------------------------------
running two Android-x86 in VirtualBox, they connect to "ethernet bridge"
--------------------------------------------------------------------------

[root@localhost virtualbox-os]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

[root@localhost virtualbox-os]# ll -h
总用量 11G
-rw-------. 1 root root 5.1G 6月  14 21:24 android-x86-6.0-rc1-1.vdi
-rw-------. 1 root root 5.1G 6月  14 21:17 android-x86-6.0-rc1-2.vdi
[root@localhost virtualbox-os]# 

brctl addbr br-android
ip link set up dev br-android
ip addr add 10.1.1.1/24 dev br-android
ip route add 10.1.1.0/24 dev br-android

ifconfig br-android down
brctl delbr br-android

// Virtual Box > Settings > Network > Adapter 1 > bridge, br-android.

// in android-x86-6.0-rc1-1
ifconfig eth0 down
ifconfig eth0 10.1.1.10 netmask 255.255.255.0 up

// in android-x86-6.0-rc1-2
ifconfig eth0 down
ifconfig eth0 10.1.1.20 netmask 255.255.255.0 up

android-x86-6.0-rc1-1 can ping android-x86-6.0-rc1-2, and vice verse

--------------------------------------------------------------------------
running two Android-x86 in VirtualBox, they connect to NS3(MANETs) via "ethernet bridge"
--------------------------------------------------------------------------

-----------
in HOST
-----------
tunctl -t tap-1
ip link set up dev tap-1
brctl addbr br-android1
brctl addif br-android1 tap-1
ip link set up dev br-android1
ip addr add 10.1.1.1/24 dev br-android1
ip route add 10.1.1.0/24 dev br-android1
-----------
tunctl -t tap-2
ip link set up dev tap-2
brctl addbr br-android2
brctl addif br-android2 tap-2
ip link set up dev br-android2
ip addr add 10.1.1.2/24 dev br-android2
ip route add 10.1.1.0/24 dev br-android2
-----------

ifconfig br-android1 down
brctl delif br-android1 tap-1
brctl delbr br-android1
ifconfig tap-1 down
tunctl -d tap-1

ifconfig br-android2 down
brctl delif br-android2 tap-2
brctl delbr br-android2
ifconfig tap-2 down
tunctl -d tap-2

-----------

[root@localhost virtualbox-os]# pwd
/run/media/root/158a840e-63fa-4544-b0b8-dc0d40c79241/virtualbox-os

[root@localhost virtualbox-os]# ll -h
总用量 11G
-rw-------. 1 root root 5.1G 6月  14 21:24 android-x86-6.0-rc1-1.vdi
-rw-------. 1 root root 5.1G 6月  14 21:17 android-x86-6.0-rc1-2.vdi
[root@localhost virtualbox-os]# 

-----------

// Virtual Box > Settings > Network > Adapter 1 > bridge, br-android1.

// in android-x86-6.0-rc1-1
ifconfig eth0 down
ifconfig eth0 10.1.1.10 netmask 255.255.255.0 up

-----------

// Virtual Box > Settings > Network > Adapter 1 > bridge, br-android2.

// in android-x86-6.0-rc1-2
ifconfig eth0 down
ifconfig eth0 10.1.1.20 netmask 255.255.255.0 up

-----------

-----------------------
running NS3
-----------------------
[root@localhost ~]# cd /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25

[root@localhost ns-3.25]# gedit scratch/manet-docker.cc 
//----------------
  TapBridgeHelper tapBridge;
  tapBridge.SetAttribute ("Mode", StringValue ("UseLocal"));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap-1"));
  tapBridge.Install (nodes.Get (0), devices.Get (0));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap-2"));
  tapBridge.Install (nodes.Get (1), devices.Get (1));
//----------------

[root@localhost ns-3.25]# ./waf --run scratch/manet-docker --vis

android-x86-6.0-rc1-1 can ping android-x86-6.0-rc1-2, and vice verse


-----------------------
So far, all is OK
-----------------------
++++++++++++++++++++++++++++++++++++++++



