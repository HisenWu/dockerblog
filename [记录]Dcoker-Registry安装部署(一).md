CentOS下Rdo安装OpenStack
=====

###1. 准备工作
####关闭防火墙:
```sh
service iptables stop        
chkconfig iptables off
```
####关闭selinux:
```sh
vi /etc/sysconfig/selinux           
SELINUX=disabled
```

####Stop and disable NetworkManager:
```sh
systemctl stop NetworkManager
systemctl disable NetworkManager
systemctl enable network
```
####系统信息
```sh
centos 7
```
###2. 安装相关的源
相关源安装相当重要，直接关系到是否可以配置成功！

####备份原来的repo
```sh
[root@localhost ~]# cd /etc/yum.repos.d/
[root@localhost yum.repos.d]# mv CentOS-Base.repo CentOS-Base.repo.backup
[root@localhost yum.repos.d]# ls
CentOS-Base.repo.backup  CentOS-Debuginfo.repo  CentOS-Sources.repo  CentOS-Vault.repo
```
####替换为本地的源
```sh

[host]# vi CentOS-Base.repo
#base
[base]
name=CentOS-$releasever - Base
baseurl=http://186.100.x.xx/repo/centos/$releasever/os/$basearch/
enable=1
gpgcheck=0

#released updates 
[updates]
name=CentOS-$releasever - Updates
baseurl=http://186.100.x.xx/repo/centos/$releasever/updates/$basearch/
enable=1
gpgcheck=0

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=http://186.100.x.xx/repo/centos/$releasever/extras/$basearch/
enable=1
gpgcheck=0
```

####安装epel源
添加本地epel源地址，如下：
```sh
[host]# vi epel.repo


[epel]
name=Extra Packages for Enterprise Linux 7 - $basearch
baseurl=http://186.100.8.148/repo/epel/7/x86_64/
failovermethod=priority
enabled=1
gpgcheck=0

```       
   
####安装RDO源      
添加本地rdo源地址，如下：
```sh
[host]# vi rdo.repo

[openstack-juno]
name=OpenStack Juno Repository
baseurl=http://186.100.x.xx/repo/openstack/openstack-juno/epel-7/
enabled=1
skip_if_unavailable=0
gpgcheck=0    
```
####刷新yum源缓存
```sh
[host]# yum clean metadata
[host]# yum makecache
```
>小技巧：
可以通过上面命令看出哪些源是不可以找到的，方便找出错误。

###3. 安装openstack-packstack
```sh
[host]# yum install -y openstack-packstack
```

####安装和运行openstack 
```sh
[host]# packstack --allinone
```

###在安装opensatck的时候，遇到了下面的问题！
####在这一步，遇到了问题。查看日志可以看出，下载下面三个包的时候出错：
```sh
Error downloading packages:
  yum-utils-1.1.31-25.el7_0.noarch: [Errno 256] No more mirrors to try.
  python-kitchen-1.1.1-5.el7.noarch: [Errno 256] No more mirrors to try.
  python-chardet-2.0.1-7.el7.noarch: [Errno 256] No more mirrors to try.
```
####不能用上面的packstack --allinone
需要修改 ~/packstack-answer-xxx-xxx.txt文件里面一个参数
```sh
[host]# cd ~ 
[host ~]# vi packstack-answers-20150316-224116.txt
//在文件里查找EPEL，将后面赋值由 n 改为 y 

[host ~]# packstack --answer-file=./packstack-answers-20150316-224116.txt 
```
####接下来，需要耐心等待！
         
-----
**如果你安装不该安装的包**
```
rpm -qa | grep xxx
rpm -e xxx-...
```

