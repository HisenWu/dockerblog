      
##目标:     
* 配置 NFS server,通过网络共享目录给client中运行的docker容器
* 测试在docker容器中操作NFS server的共享目录

>注意:
防火墙和selinux

##NFS服务和RPC简单介绍

NFS 是Network File System的缩写，即网络文件系统。          
    基本功能：通过网络让不同的机器、不同的操作系统能够彼此分享个别的数据，让应用程序在客户端通过网络访问位于服务器磁盘中的数据，是在类Unix系统间实现磁盘文件共享的一种方法。       
    基本原则：“容许不同的客户端及服务端通过一组RPC分享相同的文件系统”。           
    依赖协议：NFS在文件传送或信息传送过程中依赖于RPC协议。           

RPC，远程过程调用 (Remote Procedure Call) 是能使客户端执行其他系统中程序的一种机制。         
    不论是NFS SERVER或者NFS CLIENT，都要启动RPC服务。         
    NFS是一个文件系统，本身是没有提供信息传输的协议和功能的，而RPC是负责负责信息的传输。        

##具体的网络环境如下:
+------------------------+　　　　　　　+---------------------------+　　+-------------------------------+        
|　 [NFS Server] 　| 　　　　　　　|　[    NFS Client    ]　 　|  　  　|　[ docker container ]　  |          
| /home/nfs_server +----------+---------+　/home/nfs_share　+------+　 /home/docker_nfs　|            
| ( 186.100.8.117 ) |　　　　　　 　|　( 186.100.8.117 )　| 　　 |　　　　　　　　　　|                
+-----------------------+　　　 　　　　+---------------------------+  　　+-------------------------------+           

>下面的配置过程，请留意命令前面[]当中的不同主机。

##系统版本信息
```shell
[nfs server]# cat /etc/issue
Fedora release 21 (Twenty One)
Kernel \r on an \m (\l)  
```   
##安装NFS
```shell
[nfs server]# rpm -qa | grep nfs
libnfsidmap-0.26-2.1.fc21.x86_64
nfs-utils-1.3.1-6.1.fc21.x86_64
```
输出上面就是已经安装NFS；如果没有安装，使用下面命令安装：
```
[nfs server] #yum install nfs-utils
```
##配置NFS
```
[nfs server]# vi exports
write setting for NFS exports
/home/nfs_share 186.100.8.0/24(insecure,rw,no_root_squash)
```
* /home/nfs_share NFS_server上的共享目录
* 186.100.8.0/24  网络中可以访问这个NFS输出目录的主机；可以指定主机IP（186.100.8.10），此处为一个子网的所有主机
* insecure：访问端口号可以大于1024
* rw：共享目录的权限，rw 是可读写的权限,只读的权限是ro
* no_root_squash：NFS 服务共享的目录的属性, 如果用户是root, 那么对这个目录就有root的权限.
* 如果有多个目录, 每个目录一行,可添加多个目录

NFS服务的配置文件为 `/etc/exports`，这个文件是NFS的主要配置文件，不过系统并没有默认值，所以这个文件不一定会存在，可能要使用vim手动建立，然后在文件里面写入配置内容。
        
    /etc/exports文件内容格式：
    <输出目录> [客户端1 选项（访问权限,用户映射,其他）] [客户端2 选项（访问权限,用户映射,其他）]


##开启NFS服务
```
[nfs server]# service nfs start
Redirecting to /bin/systemctl start  nfs.service
```
##查看NFS状态
```shell
[nfs server]# service nfs status    
Redirecting to /bin/systemctl status  nfs.service   
?.nfs-server.service - NFS server and services    
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; disabled)
   Active: active (exited) since Wed 2015-03-11 22:35:11 EDT; 20s ago
  Process: 1767 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS (code=exited, status=0/SUCCESS)
  Process: 1764 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 1767 (code=exited, status=0/SUCCESS)
 ```
 ##查看端口信息
 ```shell
[nfs server]# rpcinfo -p
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  51292  status
    100024    1   tcp  36325  status
    100005    1   udp  20048  mountd
    100005    1   tcp  20048  mountd
    100005    2   udp  20048  mountd
    100005    2   tcp  20048  mountd
    100005    3   udp  20048  mountd
    100005    3   tcp  20048  mountd
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    3   udp   2049  nfs_acl
    100021    1   udp  33893  nlockmgr
    100021    3   udp  33893  nlockmgr
    100021    4   udp  33893  nlockmgr
    100021    1   tcp  59360  nlockmgr
    100021    3   tcp  59360  nlockmgr
    100021    4   tcp  59360  nlockmgr
```
##在client上查看
```shell
[client]# showmount -e  186.100.8.117
clnt_create: RPC: Port mapper failure - Unable to receive: errno 113 (No route to host)
```
###在client上使用 No route to host
```shell
[client]# mount -t nfs 186.100.8.117:/home/nfs_share /home/client_nfs/
mount.nfs: Connection timed out
```
###关闭Fedora的防火墙:
```
[nfs server]# systemctl stop firewalld.service
```
```
[client]# mount -t nfs 186.100.8.117:/home/nfs_share /home/client_nfs/
mount.nfs: access denied by server while mounting 186.100.8.117:/home/nfs_share
```
原来是把exports里面的地址配错了。
##在nfs client上查看共享目录
```shell
[client]# df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/fedora--server-root   45G  4.9G   38G  12% /
devtmpfs                         1.9G     0  1.9G   0% /dev
tmpfs                            1.9G     0  1.9G   0% /dev/shm
tmpfs                            1.9G  372K  1.9G   1% /run
tmpfs                            1.9G     0  1.9G   0% /sys/fs/cgroup
tmpfs                            1.9G  4.0K  1.9G   1% /tmp
/dev/sda1                        477M  129M  319M  29% /boot
tmpfs                            377M     0  377M   0% /run/user/0
186.100.8.117:/home/nfs_share    3.1T  2.1G  3.0T   1% /home/client_nfs
```
##在nfs client上启docker容器
```
[client]#docker run -i -t -rm --privileged -v /dev/sdb:/dev/sdb_test centos:latest /bin/bash
```
##在容器里查看共享目录
```shell
[docker]# df -h
Filesystem                                                                                        Size  Used Avail Use% Mounted on
/dev/mapper/docker-253:1-656482-b663ad112f59849ba533cea1879c0e2744642dc817546bf37084d54fb6d20dea  9.8G  246M  9.0G   3% /
tmpfs                                                                                             1.9G     0  1.9G   0% /dev
shm                                                                                                64M     0   64M   0% /dev/shm
/dev/mapper/fedora--server-root                                                                    45G  4.9G   38G  12% /etc/hosts
186.100.8.117:/home/nfs_share                                                                     3.1T  2.1G  3.0T   1% /home/docker_nfs
```
