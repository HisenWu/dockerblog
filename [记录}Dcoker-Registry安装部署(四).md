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
[registry]# yum install httpd
```      
####2. 设置Apache服务的启动级别
```sh
[registry]# chkconfig --levels 235 httpd on
Note: Forwarding request to 'systemctl enable httpd.service'.
ln -s '/usr/lib/systemd/system/httpd.service' '/etc/systemd/system/multi-user.target.wants/httpd.service'
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
[registry]# service httpd start
Redirecting to /bin/systemctl start  httpd.service
```

####4. 验证是否安装成功       
现在打开http://ip地址，看看有没有Apache的默认页面出来了？如果有就对了。

> 安装目录介绍      
* Apache默认将网站的根目录指向/var/www/html 目录 
* 默认的主配置文件是/etc/httpd/conf/httpd.conf
* 配置存储在的/etc/httpd/conf.d/目录

###Registry Vhost配置
####在安装好httpd（apache）之后，还需要下载mod_wsgi。       

>mod_wsgi：A WSGI interface for Python web applications in Apache.               

添加配置文件：/etc/httpd/conf.d/wsgi-docker-index.conf，内容如下：
```sh
[registry]# /etc/httpd/conf.d
[registry]# vi wsgi-docker-index.conf

<VirtulHost *:443>
    ServerName www.abc.com
    DocumentRoot /usr/lib64/python2.6/site-packages/docker_index
    WSGIScriptAlias /  /usr/lib64/python2.6/site-packages/docker_index/wsgi.py
    ErrorLog /var/log/docker-index/apache24.log
    CustomLog /var/log/docker-index/apache-custom.log common
    LogLevel debug
    <Directory /usr/lib64/python2.6/site-packages/docker_index>
        Order allow,deny
        Allow from all
    </Directory>
    LimitRequestLine 80000
    LimitRequestFieldSize 80000
    WSGIPassAuthorization On
    WSGIChunkedRequest On
    SSLEngine on
    SSLCertificateFile /home/index-cert/service-index.crt
    SSLCertificateKeyFile /home/index-cert/service-index.key

</VirtualHost>
Listen 443
```
####使apache httpd服务加载wsgi_module扩展。
将下载的mod_wsgi.so置于apache serverr安装目录的modules文件下，在httpd.conf文件中添加如下一行： 
```sh
//可以全局搜索文件mod_wsgi.so（名字写完整，或者你使用通配符*）
[registry]# find / -name mod_wsgi.so
/usr/lib64/httpd/modules/mod_wsgi.so
[registry]# cd /etc/httpd/conf
[registry]# vi httpd.conf 
...
LoadModule wsgi_module /usr/lib64/httpd/modules/mod_wsgi.so
...
```
通过分析，可以知道：/etc/httpd/conf.modules.d下面的配置文件均可以被加载。      
在/etc/httpd/conf/httpd.conf 文件里面有：Include conf.modules.d/*.conf。
```sh
[registry conf.modules.d]# ls
00-base.conf  00-dav.conf  00-lua.conf  00-mpm.conf  00-proxy.conf  00-systemd.conf  01-cgi.conf  10-wsgi.conf
[registry conf.modules.d]# cat 10-wsgi.conf 
LoadModule wsgi_module modules/mod_wsgi.so
[registry httpd]# ll
...
lrwxrwxrwx. 1 root root   29 Mar 17 22:37 modules -> ../../usr/lib64/httpd/modules
...
```
最终就是加载了/usr/lib64/httpd/modules下的module，mod_wsgi.so当然也就会被加载。      
```sh
//重启服务
[registry]# service httpd restart
Redirecting to /bin/systemctl restart  httpd.service
```


####


