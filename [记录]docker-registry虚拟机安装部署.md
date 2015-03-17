
###安装git，clone服务器代码
在/home下创建git_registry仓库，并下载本地服务器代码
```sh
[registry]# yum install git
[registry home]# mkdir git_registry
[registry home]# cd git_registry/
[registry git_registry]# git init
Initialized empty Git repository in /home/git_registry/.git/
//注意：不要配置代理
//从本地服务器上下载代码
[registry]# git clone http://186.100.8.145/docker_registry
```

###安装registry，替换docker_registry下的代码
安装registry的作用：下载完整的registry包，解决依赖关系，再替换掉里面更改的部分，具体目录如下。
```sh
[registry]# cd /usr/lib/python2.7/site-packages/docker-registry/
[registry docker-registry]# ls
docker_registry  test
//将原有的备份
[registry docker-registry]# mv docker_registry docker_registry_backup
[registry docker-registry]# ls
docker_registry_backup  test
//copy下载的代码过来
[registry docker-registry]# cp -r /home/git_registry/docker_registry/ .
[registry docker-registry]# ls
docker_registry  docker_registry_backup  test
```

###Docker-registry服务配置
修改配置文件的配置项：/etc/docker-registry.yml

```sh
# By default, the registry acts standalone (eg: doesn't query the index)
    # standalone: _env:STANDALONE:true
    standalone: _env:STANDALONE:false   //modify
# The default endpoint to use (if NOT standalone) is index.docker.io
    #index_endpoint: _env:INDEX_ENDPOINT:https://index.docker.io
    index_endpoint: _env:INDEX_ENDPOINT:https://www.abc.com    //modify
# Storage redirect is disabled
    storage_redirect: _env:STORAGE_REDIRECT
# Token auth is enabled (if NOT standalone)
    disable_token_auth: _env:DISABLE_TOKEN_AUTH + :false

...

# This flavor is for storing images in Openstack Swift
swift: &swift
    <<: *common
    storage: swift
    storage_path: _env:STORAGE_PATH:/registry
    # keystone authorization
    //都增加了+后面的东西
    swift_authurl: _env:OS_AUTH_URL + :"https://localdomain.com:8023/identity/v2.0"
    swift_container: _env:OS_CONTAINER + :docker
    swift_user: _env:OS_USERNAME + :nova
    swift_password: _env:OS_PASSWORD + :FusionSphere123
    swift_tenant_name: _env:OS_TENANT_NAME + :service
    swift_region_name: _env:OS_REGION_NAME + :az1.dc1
```
###Apache配置

####生成自签名证书
Index和registry都需要证书，这里采用自签名的证书，对应的域名分别是www.abc.com和registry.abc.com，生成过程如下：         
参见具体的过程，[详细命令解释](http://rhythm-zju.blog.163.com/blog/static/310042008015115718637/)
1. 首先要生成服务器端的私钥(key文件):        
先来生成Index的证书：       

**openssl genrsa -des3 -out server.key 1024**

* genrsa        
用于生成 RSA 密钥对的 OpenSSL 命令。
* -des3         
使用 3-DES 对称加密算法加密密钥对，该参数需要用户在密钥生成过程中输入一个口令用于加密。      
今后使用该密钥对时，需要输入相应的口令。如果不加该选项，则不对密钥进行加密。
* -out server.key        
令生成的密钥对保存到文件 server.key 。
* 1024       
RSA 模数位数，在一定程度上表征了密钥强度。

```sh
[registry certify]# openssl genrsa -des3 -out server.key 1024
Generating RSA private key, 1024 bit long modulus
..............................................++++++
....................++++++
e is 65537 (0x10001)
//下面phrase输入的是：www.abc.com
Enter pass phrase for server.key:
Verifying - Enter pass phrase for server.key:
[registry certify]# ls
server.key
```

2. 生成CA证书请求     
为了获取一个CA根证书，我们需要先制作一份证书请求。先前生成的 CA 密钥对被用于对证书请求签名。     
**openssl req -new -key server.key -out server.csr  （Common Name需输入www.abc.com）**     
* req      
用于生成证书请求的 OpenSSL 命令。
* -new       
生成一个新的证书请求。该参数将令 OpenSSL 在证书请求生成过程中要求用户填写一些相应的字段。      
这个选项用于生成一个新的证书请求，并提示用户输入个人信息。       
如果没有指定-key 则会先生成一个私钥文件，再生成证书请求。       

```sh
[registry]# openssl req -new -key server.key -out server.csr    
```
//生成的csr文件交给CA签名后形成服务端自己的证书
//该命令将提示用户输入密钥口令并填写证书相关信息字段，输出如下：
```
Country Name (2 letter code) [XX]:cn
State or Province Name (full name) []:sx
Locality Name (eg, city) [Default City]:xa
Organization Name (eg, company) [Default Company Ltd]:some Ltd
Organizational Unit Name (eg, section) []:design
//特别注意：Common Name 需输入 www.abc.com
Common Name (eg, your name or your server's hostname) []:www.abc.com
Email Address []:aaa

Please enter the following 'extra' attributes
to be sent with your certificate request
//下面两行直接enter
A challenge password []:
An optional company name []:
```

3. 去除key文件口令的命令
以后每当需读取此文件(通过openssl提供的命令或API)都需输入口令。        
如果觉得不方便,也可以去除这个口令,但一定要采取其他的保护措施!
**openssl rsa -in server.key.org -out service-index.key**
```sh
[registry]# openssl rsa -in server.key -out service-index.key
Enter pass phrase for server.key:
writing RSA key
```
####
**openssl x509 -req -days 365 -in server.csr -signkey service-index.key -out service-index.crt**

