经过折腾，在浏览器终于可以看到OpenStack的图标了。搭建过程参考：[CentOS下Rdo安装OpenStack](https://github.com/HisenWu/dockerblog/blob/master/%5B记录%5DCentOS下Rdo安装OpenStack.md)

###浏览器查看操作
接下来，登陆上浏览器，用户名和密码，查看~/keystonerc_admin文件。     

```sh
[openstack ~]# ls
[openstack ~]# anaconda-ks.cfg  keystonerc_admin  keystonerc_demo  packstack-answers-20150316-224116.txt
[openstack ~]# vi keystonerc_admin 
```
###在命令行下，也可以查看和操作   
执行keystonerc_admin，导入环境变量，再查看用户表和角色表。
```sh
[openstack ~]# source keystonerc_admin 
[opensatck ~(keystone_admin)]# keystone user-list
[opensatck ~(keystone_admin)]# keystone role-list
```

