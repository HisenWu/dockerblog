Docker Registry虚拟机配置
--------

##任务：服务配置    
* apache安装
* Docker-index服务配置 （/etc/docker-index.conf)
* Index Vhost配置
* Registry Vhost配置      

###apache安装
Apache在Linux系统中，其实叫“httpd”，使用yum安装Apache：      

####1. 安装Apache        
```sh
yum install httpd
```      
####2. 设置Apache服务的启动级别
```sh
chkconfig --levels 235 httpd on
```
>Apache是一个服务，所以，可以通过设置服务的启动级别来让它启动。
>等级0表示：表示关机         
>等级1表示：单用户模式          
>等级2表示：无网络连接的多用户命令行模式            
>等级3表示：有网络连接的多用户命令行模式           
>等级4表示：不可用                  
>等级5表示：带图形界面的多用户模式                
>等级6表示：重新启动                   
       
####3. 现在就启动它    
```sh
/etc/init.d/httpd start
```

####4. 验证是否安装成功       
现在打开http://ip地址，看看有没有Apache的默认页面出来了？如果有就对了。

> 安装目录介绍      
* Apache默认将网站的根目录指向/var/www/html 目录 
* 默认的主配置文件是/etc/httpd/conf/httpd.conf
* 配置存储在的/etc/httpd/conf.d/目录

###Registry Vhost配置






