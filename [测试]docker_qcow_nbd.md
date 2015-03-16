
##目的：     
将通过NFS共享的qcow2文件，在client上通过qemu-nbd工具制作成nbd设备，让docker容器可以共享操作该设备。     

###一点基础知识
* QCOW2是目前QEMU（qemu-kvm）推荐使用的guest镜像文件格式，在KVM、Xen虚拟化中的使用都是比较广泛的。
* qcow2的表现形式：在一个镜像文件中模拟一个固定大小的块设备。

##server安装qumu-img
```sh
[server]# yum install qemu-img

[server]# qemu-img create -f qcow2 nfs_test.qcow2 5G
Formatting 'nfs_test.qcow2', fmt=qcow2 size=5368709120 encryption=off cluster_size=65536 lazy_refcounts=off
```
##client上的操作
###client安装qumu-img
```sh
[client]# yum install qemu-img
```
###在client上，通过qemu-nbd工具，连接/dev/nbd0和nfs_test.qcow2     

将qcow2镜像映射为网络块设备(nbd)
```
[client]# qemu-nbd -c /dev/nbd0 nfs_test.qcow2 
Failed to open /dev/nbd0: No such file or directory
nbd.c:nbd_receive_request():L756: read failed
```
###由于没有加载nbd模块，所以dev下没有nbd设备。
```sh
[client]# grep NBD /boot/config-3.17.4-301.fc21.x86_64 
CONFIG_BLK_DEV_NBD=m
```
###内核加载nbd模块
```
[client]# modprobe nbd max_part=16
```
>卸载模块（modprobe -r nbd）   

###查看nbd模块启动后，/dev/下多了16个nbd设备
```
[root@localhost client_nfs]# ls /dev/nbd
nbd0   nbd1   nbd10  nbd11  nbd12  nbd13  nbd14  nbd15  nbd2   nbd3   nbd4   nbd5   nbd6   nbd7   nbd8   nbd9

[client]# modinfo nbd
filename:       /lib/modules/3.17.4-301.fc21.x86_64/kernel/drivers/block/nbd.ko.xz
license:        GPL
description:    Network Block Device
depends:        
intree:         Y
vermagic:       3.17.4-301.fc21.x86_64 SMP mod_unload 
signer:         Fedora kernel signing key
sig_key:        4C:74:34:E0:6F:FA:84:0A:EA:AA:9E:91:F7:66:C5:FD:A0:77:12:60
sig_hashalgo:   sha256
parm:           nbds_max:number of network block devices to initialize (default: 16) (int)
parm:           max_part:number of partitions per device (default: 0) (int)
parm:           debugflags:flags for controlling debug output (int)      
```
###通过NFS共享目录
```
[client]# mount -t nfs 186.100.8.117:/home/nfs_share /home/client_nfs/
```
###利用qemu-nbd把qcow2文件映射为网络设备（NBD）【file->block】
```
[client]# qemu-nbd -c /dev/nbd0 nfs_test.qcow2
```
###像普通block设备那样使用刚才映射好的网络设备
####为网络设备制作文件系统
```
[client]# mkfs.ext2 /dev/nbd0
mke2fs 1.42.11 (09-Jul-2014)
Discarding device blocks: failed - Input/output error
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: 6c6b0863-8cc4-43f5-9ad6-b59bc2df5beb
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376

Allocating group tables: done                            
Writing inode tables: done                            
Writing superblocks and filesystem accounting information: done
```
####一点疑问
本地的qcow2镜像（文件）映射到网络设备nbd0,为网络设备nbd0制作文件系统，挂载到/mnt下，
执行操作（添加a.txt文件）相当于写入到nbd0（有文件系统）里，其实最终是写入到qcow2这个文件里了，后面可以通过tail查看。
```
[root@localhost client_nfs]# ll /dev/nbd0*
brw-rw----. 1 root disk 43, 0 Mar 13 20:32 /dev/nbd0
[root@localhost client_nfs]# mount /dev/nbd0 /mnt/
```

##容器中的操作
###启动容器、挂载共享设备并操作
```sh
docker run -i -t --rm --privileged -v /dev/nbd1:/home/nbd_container centos /bin/bash

[root@1029c2713302 /]# mount /home/nbd_container /mnt
[root@1029c2713302 /]# cd /mnt/
[root@1029c2713302 mnt]# ls
a.txt  lost+found
[root@1029c2713302 mnt]# vi container.txt
[root@1029c2713302 mnt]# ls /mnt/
a.txt  container.txt  lost+found
```
###在client查看增加的文件
```sh
[root@localhost client_nfs]# mount /dev/nbd1 /mnt/
[root@localhost client_nfs]# ls /mnt/
a.txt  container.txt  lost+found
```
###解除关联和卸载nbd设备
使用完这个qcow2镜像后，卸载已挂载的nbd设备，解除qcow2镜像与nbd设备的关联。
```sh
[client]# umount /mnt
[client]# qemu-nbd -d /home/client_nfs/nfs_test.qcow2 
/home/client_nfs/nfs_test.qcow2 disconnected
[client]# umount /mnt
[root@localhost mnt]# tail a.txt 
create file in hostA
create file in hostA

[root@localhost mnt]# tail container.txt 
create file in container
create file in container
```
---
###关于磁盘、文件系统的一点总结

1 在使用硬盘之前必须对其分区进行格式化（做文件系统）,并挂载。
```sh
   [root@localhost ~]#mkfs.ext3 /dev/hdd1
```
2 创建挂载目录
```
   [root@localhost ~]#mkdir /hdd_mnt
```
3 挂载/dev/hdd1 /dev/hdd2
```
   [root@localhost ~]#mount /dev/hdd1 /hdd_mnt
```
4 查看
```
   [root@localhost ~]#df -h 
   另外，(-T)可以查看block设备所制作的文件系统。
```


