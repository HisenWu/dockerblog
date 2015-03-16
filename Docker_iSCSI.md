##目标：两台host主机共享磁盘设备
        
---      

##target端配置
target端即磁盘阵列或其他装有磁盘的主机。        
通过iscsitarget工具将磁盘空间映射到网络上，initiator端就可以寻找发现并使用该磁盘。
>注意，一个target主机上可以映射多个target到网络上，即可以映射多个块设备到网络上。


##inititor端配置

安装
[root@localhost sbin]# yum install scsi-target-utils

建立所需要分享的磁盘设备
[root@localhost dev]# dd if=/dev/zero of=floppy.img bs=512 count=1880
1880+0 records in
1880+0 records out
962560 bytes (963 kB) copied, 0.0017846 s, 539 MB/s
[root@localhost dev]# losetup /dev/lo
log           loop0         loop1         loop2         loop-control  
[root@localhost dev]# losetup /dev/loop8 floppy.img 
[root@localhost dev]# ll loop
loop0         loop1         loop2         loop8         loop-control


[root@localhost sbin]# tgtadm --lld iscsi --op new --mode target --tid 1 -T iqn.2015-03.com.huawei:designDisk
[root@localhost sbin]# tgtadm --lld iscsi --op show --mode target
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
    Account information:
    ACL information:

添加访问控制列表
[root@localhost dev]# tgtadm --lld iscsi --op bind --mode target --tid 1 -I 186.100.8.0/24
[root@localhost dev]# tgtadm --lld iscsi --op show --mode target
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
    	

添加LUN（logical unit）
[root@localhost dev]# tgtadm --lld iscsi --op new --mode logicalunit --tid 1 --lun 1 -b /dev/loop8

[root@localhost dev]# tgtadm --lld iscsi --op show --mode target
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

	
[initiator]# yum install iscsi-initiator-utils

[initiator]# service iscsi start	

[initiator]# iscsiadm -m discovery -t sendtargets -p 186.100.8.117
186.100.8.117:3260,1 iqn.2015-03.com.huawei:designDisk

[initiator]# cd /var/lib/iscsi/send_targets/186.100.8.117,3260/
[initiator 186.100.8.117,3260]#ll
total 8
lrwxrwxrwx. 1 root root  75 Mar 12 20:31 iqn.2015-03.com.huawei:designDisk,186.100.8.117,3260,1,default -> /var/lib/iscsi/nodes/iqn.2015-03.com.huawei:designDisk/186.100.8.117,3260,1
//表明客户端已经成功发现服务端共享target并连接到本地上来了；  

登陆到服务器target上
[initiator]# iscsiadm -m node -T iqn.2015-03.com.huawei:designDisk -p 186.100.8.117:3260 -l
Logging in to [iface: default, target: iqn.2015-03.com.huawei:designDisk, portal: 186.100.8.117,3260] (multiple)
Login to [iface: default, target: iqn.2015-03.com.huawei:designDisk, portal: 186.100.8.117,3260] successful.

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

再查看target的信息
[target]# tgtadm --lld iscsi --op show --mode target
Target 1: iqn.2015-03.com.huawei:designDisk
    System information:
        Driver: iscsi
        State: ready
    I_T nexus information:
        I_T nexus: 1
            Initiator: iqn.1994-05.com.redhat:d468b65a421 alias: initiator1
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
[initiator]# ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sdb

创建a.txt，并将其写入共享block
[initiator docker]# echo "hello world" >a.txt
[initiator docker]# dd if=a.txt of=/dev/sdb_test 
0+1 records in
0+1 records out
12 bytes (12 B) copied, 6.9711e-05 s, 172 kB/s

验证：查看已修改的共享block
[target]# dd if=/dev/loop8 of=c.txt bs=512 count=1
1+0 records in
1+0 records out
512 bytes (512 B) copied, 0.000108951 s, 4.7 MB/s
[root@localhost yum.repos.d]# cat c.txt 
hello world
