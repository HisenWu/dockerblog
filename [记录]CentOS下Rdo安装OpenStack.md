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
>**这里用部门服务器的源，具体参见附录。(就是之前配置本地服务器的源）**

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
####单独搜索安装
```sh
[host]# yum search yum-utils
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
####需要配置epel源，将外网配置上！？
```sh
stderr: Warning: Permanently added '186.100.40.211' (ECDSA) to the list of known hosts.
+ trap t ERR
+ yum install -y puppet hiera openssh-clients tar nc rubygem-json
Error: Package: hiera-1.0.0-3.el6.noarch (epel)
           Requires: ruby(abi) = 1.8
Error: Package: facter-1.6.18-3.el6.x86_64 (epel)
           Requires: ruby(abi) = 1.8
Error: Package: ruby-augeas-0.4.1-1.el6.x86_64 (epel)
           Requires: ruby(abi) = 1.8
Error: Package: ruby-shadow-1.4.1-13.el6.x86_64 (epel)
           Requires: ruby(abi) = 1.8
Error: Package: puppet-2.7.25-2.el6.noarch (epel)
           Requires: ruby(abi) >= 1.8
Error: Package: ruby-augeas-0.4.1-1.el6.x86_64 (epel)
           Requires: libruby.so.1.8()(64bit)
Error: Package: ruby-shadow-1.4.1-13.el6.x86_64 (epel)
           Requires: libruby.so.1.8()(64bit)
++ t
++ exit 1
```
         
**如果你安装不该安装的包**
```
rpm -qa | grep xxx
rpm -e xxx-...
```

