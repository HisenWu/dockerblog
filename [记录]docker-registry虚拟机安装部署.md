
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
