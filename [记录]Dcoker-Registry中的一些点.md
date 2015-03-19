一些技术点的理解记录    
------
####VHost
虚拟主机 (Virtual Host) 是在同一台机器搭建属于不同域名或者基于不同 IP 的多个服务的技术。    

* Index VHost  --  配置文件wsgi-docker-index.conf
* Registry VHost    --    配置文件wsgi-docker-registry.conf

####https的SSL证书不能用IP地址      

/etc/hosts下进行ip地址和域名进行对应      

####配置决定是否进行鉴权
* 不鉴权    

```sh
By default, the registry acts standalone (eg: doesn't query the index)
    standalone: _env:STANDALONE:true
Token auth is enabled (if NOT standalone)
    disable_token_auth: _env:DISABLE_TOKEN_AUTH:true
```
* 鉴权    
```sh
By default, the registry acts standalone (eg: doesn't query the index)
    standalone: _env:STANDALONE:false
Token auth is enabled (if NOT standalone)
    disable_token_auth: _env:DISABLE_TOKEN_AUTH:false   
```
