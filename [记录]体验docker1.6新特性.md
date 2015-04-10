###安装docker1.6
#####1. 下载docker1.6的可执行文件
本机下载此版本：[Linux 64bit tgz](https://test.docker.com/builds/Linux/x86_64/docker-1.6.0-rc5.tgz)
```shell
# curl -sSL -O https://test.docker.com/builds/Linux/x86_64/docker-1.6.0-rc5
# chmod +x docker-1.6.0-rc5
```
#####2.  关闭本机docker服务，并替换当前docker
```sh
# service stop docker
# mv docker-1.6.0-rc5 /usr/bin/docker
```
#####3.  启动docker服务，查看替换后的版本
```shell
# service start docker
# docker version
Client version: 1.6.0-rc5
...
Server version: 1.6.0-rc5
...
```
###dokcer新特性
更详细信息，查看docker源码rc 1.6下的[Changelog](https://github.com/docker/docker/tree/v1.6.0-rc5/CHANGELOG.md)。
####1.6.0 ( 2015-04-07 )        
####Builder   
* Building images from an image ID
* build containers with resource constraints, ie `docker build --cpu-shares=100 --memory=1024m...`
* `commit --change` to apply specified Dockerfile instructions while committing the image
* `import --change `to apply specified Dockerfile instructions while importing the image

####Client
* Windows Support
>注：Mac客户端是[Kitmatic](https://Kitmatic.com)     

####Runtime
* Container and image Labels
* `--cgroup-parent` for specifying a parent cgroup to place container cgroup within
* Logging drivers, `json-file`,` syslog`, or `none`
* Pulling images by ID    
* `--ulimit` to set the ulimit on a container
* `--default-ulimit` option on the daemon which applies to all created containers (and overwritten by `--ulimit` on run)

###新特性体验
####本文主要体验runtime的新特性
####LABEL可以支持：     

* Dockerfile，label image
* Runtime，label container      

现在除了通过指定容器名字找到所启动的容器，还可以通过label来快速定位查看容器状态。
```sh
# docker run --privileged -itd --label foo=bar centos
314197b8f2179c9486030ff6c9c6dd51da7438323171e5a94f4ec4e86f1c9f99

# docker ps -f label=foo=bar
CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS              PORTS               NAMES
314197b8f217        centos:latest       "/bin/bash"         About a minute ago   Up About a minute                       hungry_galileo
```
>[关于label更多讨论内容](https://github.com/docker/docker/pull/9882)     

####Logging drivers     
```docker --help```可以看到docker1.6支持log-driver，支持的类型有：**json-file，syslog，none**。默认类型为：`json-file`，而且只有json-file类型支持`docker logs [container]`命令。
```
--log-driver=json-file               Containers logging driver
```
```sh
# docker run --privileged -itd --log-driver="syslog" centos
136974fe2d2a059d25f93d03c97a09bc5451119db9e96c05297f30f7c37b8d35
# docker inspect 136974fe2d2a***8d35
...
"LogConfig": {
            "Config": null,
            "Type": "syslog"
             },
...
"LogPath": "",
...
# docker logs 136974fe2d2a***8d35
FATA[0000] "logs" command is supported only for "json-file" logging driver
```
查看当前容器可以看到Type是指定的syslog，但是Config和LogPath均未指定，查询得知：
 "this is currently not used"  and  “keep it as extension point in the future drivers”。        
 
 >注：具体[查看issue](https://github.com/docker/docker/issues/4934)                      
 
####支持容器设置ulimit
**ulimit的作用：设置启动容器所占有的资源，实现系统资源的合理限制和分配。**
linux系统中有ulimit 指令，对资源限制和系统性能优化提供了一条便捷的途径。从用户的 shell启动脚本，应用程序启动脚本，以及直接在控制台，都可以通过该指令限制系统资源的使用，包括所创建的内核文件的大小、进程数据块的大小、Shell进程创建文件的大小、内存锁住的大小、常驻内存集的大小、打开文件描述符的数量、分配堆栈的最大大小、CPU时间、单个用户的最大线程数、Shell进程所能使用的最大虚拟内存，等等方面。[更多介绍](https://www.ibm.com/developerworks/cn/linux/l-cn-ulimit/)                      
```sh
[host]# docker run --privileged -it --ulimit data=8192 centos /bin/bash
```
在容器中查看设置的值是否生效。
```sh
[container]# ulimit -a
```
查看[ulimit.go源码](https://github.com/docker/docker/blob/master/pkg/ulimit/ulimit.go)，找到ulimit可设置的所有参数命令。
```sh
"core":       RLIMIT_CORE,                                            
"cpu":        RLIMIT_CPU,                       
"data":       RLIMIT_DATA,                      
"fsize":      RLIMIT_FSIZE,
"locks":      RLIMIT_LOCKS,
"memlock":    RLIMIT_MEMLOCK,
"msgqueue":   RLIMIT_MSGQUEUE,
"nice":       RLIMIT_NICE,
"nofile":     RLIMIT_NOFILE,
"nproc":      RLIMIT_NPROC,
"rss":        RLIMIT_RSS,
"rtprio":     RLIMIT_RTPRIO,
"rttime":     RLIMIT_RTTIME,
"sigpending": RLIMIT_SIGPENDING,
"stack":      RLIMIT_STACK,
```
对应Linux下的ulimit -a显示的信息。
```shell
core file size          (blocks, -c) unlimited
data seg size           (kbytes, -d) 1000
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 14981
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) 1000
open files                      (-n) 1048576
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 1048576
virtual memory          (kbytes, -v) 1000
file locks                      (-x) unlimited
```
------
####测试每一个命令，确定对应关系，如有不对请指出！      

#####**测试目的：**
* ulimit指令在docker和Linux下作对应
* 测试后发现，docker ulimit设置关于存储的值，在Linux下查看需要除以1024（单位不一样）

#####测试命令
```sh
# docker run --privileged -it --rm --ulimit xxx=5000 centos /bin/bash
```
#####测试结果
```sh
[host]#docker --ulimit xxx =         number        [container]#ulimit xx            值

            "core":                  5000                   -c,                     4                    
            "cpu":                   5000                   -t,                     5000 
            "data":                  5000                   -d,                     4
            "fsize":                 5000                   -f,                     4
            "locks":                 5000                   -x,                     5000
            "memlock":               5000                   -l,                     4
            "msgqueue":              5000                   -q,                     5000
            "nice":                  5000                   -e,                     5000
            "nofile":                5000                   -n,                     5000
            "nproc":                 5000                   -u,                     5000
            "rss":                   5000                   -m,                     4
            "rtprio":                5000                   -r,                     5000
            "rttime":                RLIMIT_RTTIME, (没找到对应的)
            "sigpending":            5000                   -i,                     5000
            "stack":                 -s (执行了，但没有进入到容器)
```
#####理解上面表格
以core为例说明：      

```[host]# docker --ulimit  core=5000 ...```
```
[container]# ulimit -c
4
```
`rttime`没有找到Linux下对应的指令~
