Docker Registry虚拟机配置
--------

##任务：测试registry    
* Docker-inex服务配置 （/etc/docker-index.conf)
* docker（xxx.xxx.40.213）机器配置
* OpenStack相关配置    


###docker机器配置  
####安装docker
[安装docker](http://wiki.centos.org/zh/Cloud/Docker)。因为使用外源，记得装好后unset代理地址。      

#### 在client虚拟机上将两个证书分别加入到可信列表中
* 从registry虚拟机上拷贝两个证书到docker客户端
```
[registry]# scp /etc/service-registry.crt root@xxx.xxx.40.213:/home/
The authenticity of host '186.100.40.213 (186.100.40.213)' can't be established.
ECDSA key fingerprint is 9b:f4:e7:a3:d3:a6:2a:c0:1a:4b:d8:ba:69:9c:ec:cf.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '186.100.40.213' (ECDSA) to the list of known hosts.
root@186.100.40.213's password: 
service-registry.crt
[registry]# scp /etc/service-index.crt root@xxx.xxx.40.213:/home/
```
* 加入到可信列表   
```
[docker]# cat /home/service-registry.crt >> /etc/ssl/certs/ca-bundle.crt      
[docker]# cat /home/service-index.crt >> /etc/ssl/certs/ca-bundle.crt
```
