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
root@186.100.40.213's password: 
service-registry.crt
[registry]# scp /etc/server-index.crt root@186.100.40.213:/home/
root@186.100.40.213's password: 
server-index.crt  
```
>注意：上面一个service-registry.crt，生成的时候名字输入为此。      

* 加入到可信列表   
```
[docker]# cat /home/service-registry.crt >> /etc/ssl/certs/ca-bundle.crt      
[docker]# cat /home/service-index.crt >> /etc/ssl/certs/ca-bundle.crt
```
