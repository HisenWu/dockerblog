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
####配置网络代理
```sh
[host]# export http_proxy=http://186.100.4.131:808
[host]# export https_proxy=http://186.100.4.131:808
[host]# export no_proxy="186.100.8.148"
```
###2. 安装相关的源
相关源安装相当重要，直接关系到是否可以配置成功！

####备份原来的repo
```sh
[root@localhost ~]# cd /etc/yum.repos.d/
[root@localhost yum.repos.d]# ls
CentOS-Base.repo  CentOS-Debuginfo.repo  CentOS-Sources.repo  CentOS-Vault.repo

[root@localhost yum.repos.d]# mv CentOS-Base.repo CentOS-Base.repo.backup
[root@localhost yum.repos.d]# ls
CentOS-Base.repo.backup  CentOS-Debuginfo.repo  CentOS-Sources.repo  CentOS-Vault.repo
```
####替换为国内的源
```sh
安装ali源，参考ali的源
[host]# vi CentOS-Base.repo
```
>**这里用部门服务器的源，具体参见附录。(就是之前配置本地服务器的源）**

####安装openstack源
注意这里单独创建openstack的源。
```sh
[host]# vi openstack.repo 
#base
[base]
name=OpenStack-$releasever - Base

baseurl=http://186.100.8.148/repo/openstack/openstack-juno/epel-7/
enable=1
gpgcheck=0

```
####安装RDO源
[host]# yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-juno/rdo-release-juno-1.noarch.rpm

####安装epel源
由于缺少，后面出现了问题。这个源，部门服务器也有。
```sh
[host]# yum install -y http://186.100.8.148/repo/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
```

####刷新yum源缓存
```sh
[host]# yum clean metadata
[host]# yum makecache
```
>小技巧：
可以通过上面命令看出哪些源是不可以找到的，方便找出错误。

###3. 安装rdo与Packstack

*-*-*-*-*-*-*-*
####安装rdo
```sh
[host]# wget https://repos.fedorapeople.org/repos/openstack/openstack-icehouse/rdo-release-icehouse-4.noarch.rpm
[host]# yum install -y rdo-release-icehouse-4.noarch.rpm

或者
[host]# yum install -y https://rdo.fedorapeople.org/rdo-release.rpm
```
*-*-*-*-*-*-*-*

####安装openstack-packstack
```sh
[host]# yum install -y openstack-packstack
```
###安装和运行openstack 
```sh
[host]# packstack --allinone
```
####在这一步，遇到了问题。查看日志可以看出，下载下面三个包的时候出错：
```sh
Error downloading packages:
  yum-utils-1.1.31-25.el7_0.noarch: [Errno 256] No more mirrors to try.
  python-kitchen-1.1.1-5.el7.noarch: [Errno 256] No more mirrors to try.
  python-chardet-2.0.1-7.el7.noarch: [Errno 256] No more mirrors to try.
```
####单独搜索安装
```sh
[host]# yum search yum-utils
[host]# packstack --allinone
Preparing servers                                 [ ERROR ]
ERROR : Failed to set EPEL repo on host 186.100.40.211:
RPM file seems to be installed, but appropriate repo file is probably missing in /etc/yum.repos.d/
```
####根据提示信息查看，是缺少了EPEL的repo
去mirrors.aliyun下载并安装：
```sh
[host]# wget http://mirrors.aliyun.com/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
[host]# yum install -y epel-release-7-5.noarch.rpm
```
用了命令rpm -Uvh，但是提示没有rpm命令；应用yum install -y安装成功。

####再执行
```sh
[host]# packstack --allinone
Warning: NetworkManager is active on 186.100.40.211. 
OpenStack networking currently does not work on systems that have the Network Manager service enabled.
```
**看来是要关闭网络**
```sh
[root@localhost ~]# chkconfig NetworkManager off
Note: Forwarding request to 'systemctl disable NetworkManager.service'.
[root@localhost ~]# systemctl disable NetworkManager.service
```
