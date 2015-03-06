目的

* 理解docker的存储方式
* docker的image和container在host上的目录结构
* docker image和container的内容与配置不同存储

Docker是一个开源的应用容器引擎，主要利用Linux内核namespace实现沙盒隔离，用Cgroup实现资源限制。Docker用于统一开发和部署的轻量级 Linux 容器，试图解决“依赖地狱”问题，把依赖的服务和组件组合起来，类似船舶使用的集装箱，达到快速安装部署。

#1. Docker的基本架构---Client和Daemon
让我们先搞明白docker的基本架构和启动过程，其实Docker 采用了C/S架构，包括客户端和服务端。Docker daemon作为服务端接受来自客户的请求，并处理这些请求（创建、运行、提交容器）。 客户端和服务端在一个机器上，通过RESTful API 来进行通信。
具体到使用的过程中，就是在执行`service docker start`后，在主机（host）上产生docker deamon守护进程，在后台运行并等待接收来自客户端的消息（即输入的docker命令，如`docker pull xxx，docker run …，docker commit xxx`），实现跟docker deamon的交互。当启动docker服务后，可以看到docker进程。
<pre><code>[root@localhost ~]# ps -aux | grep docker
root     11701  0.0  0.4 359208 16624 ?        Ssl  21:05   0:00 /usr/bin/docker -d -H fd:// --selinux-enabled --insecure-registry 186.100.8.216:5000
root     11861  0.0  0.0 113004  2256 pts/0    S+   23:01   0:00 grep --color=auto docker
</code></pre>
说明这个，主要是后面指定文件系统的时候，需要先在`/etc/sysconfig/docker`的配置具体的storage driver（这个会写一篇专门的Blog），然后再启动Docker Daemon，而不能通过run命令的参数进行操作。还可以直接在host命令行通过`docker –d`进行设置。
#2. Docker的存储方式---Storage Driver
Docker模型的核心部分是有效利用分层镜像机制，镜像可以通过分层来进行继承，基于基础镜像（没有父镜像），可以制作各种具体的应用镜像。不同 Docker 容器就可以共享一些基础的文件系统层，同时再加上自己独有的改动层，大大提高了存储的效率。其中主要的机制就是分层模型和将不同目录挂载到同一个虚拟文件系统下（unite several directories into a single virtual filesystem，来自[这篇文章](http://jpetazzo.github.io/assets/2015-03-03-not-so-deep-dive-into-docker-storage-drivers.html#10)）。    针对镜像存储docker采用了几种不同的存储drivers，包括：aufs，devicemapper，btrfs 和overlay（来自[官网](http://docs.docker.com/reference/commandline/cli/#option-types)）。下面简单对不同的存储drivers做个介绍。
##AUFS
AUFS（AnotherUnionFS）是一种联合文件系统。 AUFS 支持为每一个成员目录（类似 Git 的分支）设定只读（readonly）、读写（readwrite）和写出（whiteout-able）权限, 同时 AUFS 里有一个类似分层的概念, 对只读权限的分支可以逻辑上进行增量地修改(不影响只读部分的)。AUFS唯一一个storage driver可以实现容器间共享可执行及可共享的运行库, 所以当你跑成千上百个拥有相同程序代码或者运行库时时候，AUFS是个相当不错的选择。
##Device mapper
Device mapper 是 Linux 2.6 内核中提供的一种从逻辑设备到物理设备的映射框架机制，在该机制下，用户可以很方便的根据自己的需要制定实现存储资源的管理策略([详见](http://www.ibm.com/developerworks/cn/linux/l-devmapper/index.html)) 。Device mapper driver 会创建一个100G的简单文件包含你的镜像和容器，每一个容器被限制在10G大小的卷内（注意：这是利用loopback自动创建的稀疏文件，具体为`/var/lib/docker/devicemapper/devicemapper` 下的data和metadata,可动态扩张）。可以调整Docker容器的大小，[具体参考](http://zhumeng8337797.blog.163.com/blog/static/100768914201452405120107/) ）
你可以在启动docker daemon时用参数-s 指定driver，也就是可以`docker -d -s devicemapper`设置docker的存储driver。先关闭docker服务，执行命令：
<pre><code>
[root@localhost ~]# docker -d -s devicemapper
INFO[0000] +job serveapi(unix:///var/run/docker.sock)   
INFO[0000] Listening for HTTP on unix (/var/run/docker.sock) 
INFO[0000] +job init_networkdriver()                    
INFO[0000] -job init_networkdriver() = OK (0)           
INFO[0000] Loading containers: start.                   
....
INFO[0000] Loading containers: done.                    
INFO[0000] docker daemon: 1.4.0 4595d4f/1.4.0; execdriver: native-0.2; graphdriver: devicemapper 
INFO[0000] +job acceptconnections()                     
INFO[0000] -job acceptconnections() = OK (0)
</code></pre>
>另外，docker在启动容器的时候可以指定 --storage-opt 参数，但是现在只有devicemapper能够接受参数设置。后面会有针对性的Blog展示。       

##BTRFS
Btrfs Driver 在docker build可以很高效。但是跟 devicemapper 一样不支持设备间共享存储(参加[官网](http://docs.docker.com/reference/commandline/cli/#option-types))。Btrfs 支持创建快照(snapshot)和克隆(clone)，还能够方便的管理多个物理设备。（详细了解可以参考[IBM对Btrfs的介绍](http://www.ibm.com/developerworks/cn/linux/l-cn-btrfs/)）
##overlay
overlay跟AUFS很像，但是性能比AUFS好，有很好内存利用，现在已经合并入Linux内核3.18了。具体使用命令：`docker –d –s overlay`     

>官网的Note:  It is currently unsupported on btrfs or any Copy on Write filesystem and should only be used over ext4 partitions.         




更多关于docker的技术文章，请访问：[team blog](http://openstack.wiaapp.cn/)
