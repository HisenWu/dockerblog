CentOS下Rdo安装OpenStack
=====

###关闭防火墙:
service iptables stop        
chkconfig iptables off

###关闭selinux:
vi /etc/sysconfig/selinux           
SELINUX=disabled

###安装epel源

####备份原来的repo
```sh
[root@localhost ~]# cd /etc/yum.repos.d/
[root@localhost yum.repos.d]# ls
CentOS-Base.repo  CentOS-Debuginfo.repo  CentOS-Sources.repo  CentOS-Vault.repo

[root@localhost yum.repos.d]# mv CentOS-Base.repo CentOS-Base.repo.backup
[root@localhost yum.repos.d]# ls
CentOS-Base.repo.backup  CentOS-Debuginfo.repo  CentOS-Sources.repo  CentOS-Vault.repo
```
####替换为国内（ali）的源
```sh
[host]# vi CentOS-Base.repo
参考ali的源
[host]# yum makecache
```


###安装rdo与Packstack

####安装rdo
```sh
[host]# wget https://repos.fedorapeople.org/repos/openstack/openstack-icehouse/rdo-release-icehouse-4.noarch.rpm
[host]# yum install -y rdo-release-icehouse-4.noarch.rpm

或者
[host]# yum install -y https://rdo.fedorapeople.org/rdo-release.rpm
```
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
