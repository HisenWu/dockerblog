##目标：两台host主机透过一个网络接口共享磁盘设备（iSCSI）
        
---      

>note：防火墙和selinux，本次关闭了防火墙

##target端和inititor端简单介绍
* target端即磁盘阵列或其他装有磁盘的主机，server端。        
* 通过iscsitarget工具将磁盘空间映射到网络上，initiator端就可以寻找发现并使用该磁盘。     
>注意，一个target主机上可以映射多个target到网络上，即可以映射多个块设备到网络上。       

* initiator就是iSCSI传输的客户端，client端。
* iSCSI initiator通过IP网络传输SCSI命令。

##target端配置
###软件安装
```sh
[target]# yum install scsi-target-utils   
```
###建立大型文件，创建所需要分享的磁盘设备,loop8
```sh
[target dev]# dd if=/dev/zero of=floppy.img bs=512 count=1880
1880+0 records in
1880+0 records out
962560 bytes (963 kB) copied, 0.0017846 s, 539 MB/s
[target dev]# losetup /dev/lo
log           loop0         loop1         loop2         loop-control  
[target dev]# losetup /dev/loop8 floppy.img 
[target dev]# ll loop
loop0         loop1         loop2         loop8         loop-control
```

###tgtadm——Linux SCSI Target管理工具

* tgtadm是用来监控、修改Linux SCSI target 的工具，包括target设置、卷设置，等。
* 提供为装有SCSI initiator的其它操作系统提供块级（block-level）的SCSI存储。
* Linux iSCSI target，通过网络向装有iSCSI initiator的系统提供存储服务。
###查看帮助文档   

```sh
[target]# tgtadm --help   
```   
[参考](http://vbird.dic.ksu.edu.tw/linux_server/0460iscsi_2.php)
>iSCSI 有一套自己分享 target 设备名的定义：    
以iqn为开头，意思是：『iSCSI Qualified Name (iSCSI 合格名称)』。     
iqn 后面通常是：`iqn.yyyy-mm.<reversed domain name>:identifier`     
所以本次取名：**iqn.2015-03.com.huawei:designDisk**        
iqn号是局域网内iSCSI target的唯一标识，用来区分不同的target，所以在一个网络内，iqn号一定不能相同!      

###设定tgt的配置文件 /etc/tgt/targets.conf     
添加下面几行配置代码：
```sh
[target]# vi /etc/tgt/targets.conf 
<target iqn.2015-03.com.huawei:designDisk>
backing-store /dev/loop8
initiator-address 186.100.8.0/24
</target>
```
以上配置等同于（===）
```sh
创建了一个id为1的target
[target] tgtadm --lld iscsi --op new --mode target --tid 1 -T iqn.2015-03.com.huawei:designDisk 
添加访问控制列表
[root@localhost dev]# tgtadm --lld iscsi --op bind --mode target --tid 1 -I 186.100.8.0/24
添加LUN（logical unit）
[root@localhost dev]# tgtadm --lld iscsi --op new --mode logicalunit --tid 1 --lun 1 -b /dev/loop8
```
###重启服务    
```sh
[target]# service iscsi start
```
###查看target端的配置信息
```sh
[target]# tgt-admin --show     
等同于（===）  
[target]# tgtadm --lld iscsi --op show --mode target
Target 1: iqn.2015-03.com.huawei:designDisk
    System information:
        Driver: iscsi
        State: ready
    I_T nexus information:
    LUN information:
        LUN: 0
            Type: controller
            SCSI ID: IET     00010000
            SCSI SN: beaf10
            Size: 0 MB, Block size: 1
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: null
            Backing store path: None
            Backing store flags: 
        LUN: 1
            Type: disk
            SCSI ID: IET     00010001
            SCSI SN: beaf11
            Size: 1 MB, Block size: 512
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: rdwr
            Backing store path: /dev/loop8
            Backing store flags: 
    Account information:
    ACL information:
        186.100.8.0/24
```

##initiator端配置
###软件安装和服务启动
```sh
[initiator]# yum install iscsi-initiator-utils
[initiator]# service iscsi start	
```
###查看initiator没有连接target时的磁盘设备
```sh
[initiator]#ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2
```
###搜索targets
通过iscsiadm命令来搜索和登录到iSCSI的target，同时它也可以读取和访问open-iscsi提供的数据库。
存储服务器(target)的ip地址为 186.100.8.117，输入：
```sh
[initiator]# iscsiadm -m discovery -t sendtargets -p 186.100.8.117
186.100.8.117:3260,1 iqn.2015-03.com.huawei:designDisk
[initiator]# cd /var/lib/iscsi/send_targets/186.100.8.117,3260/
[initiator 186.100.8.117,3260]#ll
total 8
lrwxrwxrwx. 1 root root  75 Mar 12 20:31 iqn.2015-03.com.huawei:designDisk,186.100.8.117,3260,1,default -> /var/lib/iscsi/nodes/iqn.2015-03.com.huawei:designDisk/186.100.8.117,3260,1
//表明客户端已经成功发现服务端共享target并连接到本地上来了；  
```
###登陆到服务器target上
```sh
[initiator]# iscsiadm -m node -T iqn.2015-03.com.huawei:designDisk -p 186.100.8.117:3260 -l
Logging in to [iface: default, target: iqn.2015-03.com.huawei:designDisk, portal: 186.100.8.117,3260] (multiple)
Login to [iface: default, target: iqn.2015-03.com.huawei:designDisk, portal: 186.100.8.117,3260] successful.
```
看到successful，证明已经登录成功了！
###可以通过日志查看
```sh
[initiator]# tail -f /var/log/messages 
Mar 12 20:37:22 localhost kernel: scsi 2:0:0:0: Attached scsi generic sg2 type 12
Mar 12 20:37:22 localhost kernel: scsi 2:0:0:1: Direct-Access     IET      VIRTUAL-DISK     0001 PQ: 0 ANSI: 5
Mar 12 20:37:22 localhost kernel: sd 2:0:0:1: Attached scsi generic sg3 type 0
Mar 12 20:37:22 localhost kernel: sd 2:0:0:1: [sdb] 1880 512-byte logical blocks: (962 kB/940 KiB)
Mar 12 20:37:22 localhost kernel: sd 2:0:0:1: [sdb] Write Protect is off
Mar 12 20:37:22 localhost kernel: sd 2:0:0:1: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Mar 12 20:37:22 localhost kernel: sdb: unknown partition table
Mar 12 20:37:22 localhost kernel: sd 2:0:0:1: [sdb] Attached SCSI disk
Mar 12 20:37:23 localhost iscsid: Could not set session1 priority. READ/WRITE throughout and latency could be affected.
Mar 12 20:37:23 localhost iscsid: Connection1:0 to [target: iqn.2015-03.com.huawei:designDisk, portal: 186.100.8.117,3260] through [iface: default] is operational now
```
###在target上，再查看target的信息
```sh
[target]# tgtadm --lld iscsi --op show --mode target
Target 1: iqn.2015-03.com.huawei:designDisk
    System information:
        Driver: iscsi
        State: ready
    I_T nexus information:
        I_T nexus: 1
            **Initiator: iqn.1994-05.com.redhat:d468b65a421 alias: initiator1**
            Connection: 0
                IP Address: 186.100.8.216
    LUN information:
        LUN: 0
            Type: controller
            SCSI ID: IET     00010000
            SCSI SN: beaf10
            Size: 0 MB, Block size: 1
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: null
            Backing store path: None
            Backing store flags: 
        LUN: 1
            Type: disk
            SCSI ID: IET     00010001
            SCSI SN: beaf11
            Size: 1 MB, Block size: 512
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: rdwr
            Backing store path: /dev/loop8
            Backing store flags: 
    Account information:
    ACL information:
        186.100.8.0/24
```
###查看initiator连接上target后的磁盘设备
```sh
[initiator]# ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sdb
```
可以看到,产生了一个sdb设备，这也就是target上的loop8设备。

##在initiator启docker容器，并将sdb与docker容器共享
```sh
[initiator]# docker run -i -t --rm --privileged -v /dev/sdb:dev/sdb_test centos /bin/bash
```
###共享设备测试
####创建a.txt，并将其写入共享block
```sh
[initiator docker]# echo "hello world" >a.txt
[initiator docker]# dd if=a.txt of=/dev/sdb_test 
0+1 records in
0+1 records out
12 bytes (12 B) copied, 6.9711e-05 s, 172 kB/s
```
####验证：查看已修改的共享block
```sh
[target]# dd if=/dev/loop8 of=c.txt bs=512 count=1
1+0 records in
1+0 records out
512 bytes (512 B) copied, 0.000108951 s, 4.7 MB/s
[target]# cat c.txt 
hello world
```
