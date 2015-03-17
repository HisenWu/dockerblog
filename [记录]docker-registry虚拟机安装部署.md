
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

###
