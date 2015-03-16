详解docker存储驱动
----
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

#3    Docker目录结构
Docker两个最重要的概念是镜像和容器。那么我们pull下来的镜像的存储在哪里呢？镜像运行容器启动后，我们的操作修改的内容存储在哪里呢？因为具体的驱动不同，所以最终的实现效果不同。下面我们以Device Mapper存储driver为例，分析下docker的存储结构。    
##1.	进入`/var/lib/docker`目录，列出内容：
<pre><code>
[root@localhost ~]# cd /var/lib/docker/
[root@localhost docker]# ls
containers  devicemapper  execdriver  graph  init  linkgraph.db  repositories-devicemapper  tmp  trust  volumes
</code></pre>         
根据目录的内容，可以明显的看到是使用了devicemapper driver。
>注：以下显示的文件夹都是在/var/lib/docker下的。      

##2.	pull的镜像文件存在哪个文件夹下呢？([参考](http://www.csdn.net/article/2014-11-20/2822693)）   
pull的镜像信息保存在了graph文件夹下，镜像的内容存在了`devicemapper/ devicemapper/data` 下。    
##3.	启动的容器运行在哪里呢？
启动的容器配置信息保存在`containers`里，查看了还有`execdriver/native/`。   
容器里操作的内容保存在`devicemapper/devicemapper/data`下。
##4.	graph的角色    
在Docker架构中扮演已下载容器镜像的保管者，以及已下载容器镜像之间关系的记录者。graph的本地目录中，关于每一个的容器镜像，具体存储的信息有：该容器镜像的元数据（json），容器镜像的大小（layersize）信息，以及该容器镜像所代表的具体rootfs。

##5.	实验测试：
###- 初始没有启容器：     
<pre><code>
[root@localhost docker]# ll containers/
total 0
</code></pre>
###- 启动一个容器：
<pre><code>
[root@localhost docker]# docker run -i -t --rm centos:7 /bin/bash
[root@187a8f9d2865 /]#
</code></pre>
所启动的容器的`UUID=187a8f9d2865`
###- 启动容器前，查看查看/var/lib/docker/devicemapper/devicemapper/下文件的实际大小
<pre><code>
[root@bhDocker216 docker]# du -h devicemapper/devicemapper/*
2.1G	devicemapper/devicemapper/data
3.5M	devicemapper/devicemapper/metadata
</code></pre>
###- 在host的主机上查看
<pre><code>
[root@bhDocker216 docker]# ls containers/
187a8f9d2865c2ac***91b981
</code></pre>
查看启动的容器在UUID文件夹下面的内容：
<pre><code>
[root@bhDocker216 containers]# ll 187a8f9d2865c2ac***91b981
total 24
-rw-------. 1 root root   273  Mar   5 23:59  187a8f9d2865***-json.log
-rw-r--r--. 1 root root  1683  Mar  5 23:58   config.json
-rw-r--r--. 1 root root   334  Mar  5 23:58   hostconfig.json
-rw-r--r--. 1 root root    13  Mar  5 23:58   hostname
-rw-r--r--. 1 root root   174  Mar  5 23:58   hosts
-rw-r--r--. 1 root root    69  Mar  5 23:58   resolv.conf
</code></pre>
###- 在启动的容器添加文件,并查看。
先在运行的容器内创建一个文件：
<pre><code>
[root@8a1e3ad05d9e /]# dd if=/dev/zero of=floppy.img bs=512 count=5760
5760+0 records in
5760+0 records out
2949120 bytes (2.9 MB) copied, 0.0126794 s, 233 MB/s
</code></pre>
然后在/var/lib/docker/devicemapper/devicemapper/下查看文件：
<pre><code>
[root@bhDocker216 docker]# du -h devicemapper/devicemapper/*
5.5G	devicemapper/devicemapper/data
4.6M	devicemapper/devicemapper/metadata
</code></pre>
这地方大小有点出入，是因为先执行了 `# dd if=/dev/zero of=test.txt bs=1M count=8000`，创建一个8G大小的文件，由于太慢我终止了，但是可以明确的看到在运行的容器里进行操作，两个文件夹都发生了改变（增加）。
###- 查看graph，在只pull了一个镜像（Ubuntu14.10）的情况下，里面出现了7个长UUID命名的目录，这是怎么来的呢？    
用` docker images –tree `列出镜像树形结构，我们可以看到镜像的分层存储结构。最终的Ubuntu（第7层）是基于第6层改动的，即这种逻辑上的树中第n层基于是第n-1层改动的，n层依赖n-1层的image。第0层，大小为0，称为base image。
###- graph/UUID目录下内容是啥呢？   
<pre><code>
[root@localhost graph]# ll 01bf15a18638145eb***  -h
total 8.0K
-rw-------. 1 root root  1.6K  Mar  5 18:02  json
-rw-------. 1 root root    9  Mar  5 18:02  layersize
</code></pre>
查看layersize的内容：数字表示层的大小（单位：B）。
josn：保存了这个镜像的元数据（如：`size，architecture，config，container，**parent的UUID**`等等）。
###- 查看devicemapper/devicemapper文件夹    
有两个文件夹`data`和`metadata`，其实device mapper driver是就是把**镜像和容器的文件**都存储在`**data**`这个文件内。可以通过docker info查看data和metadata的大小。
另外可以用`du –h`（上面有用到）查看这两个稀疏文件的实际大小。

###- execdriver
<pre><code>
[root@bhDocker216 docker]# ls execdriver/native/
8a1e3ad05d9e66a455e683a2c***2437bdcccdfdfa
//对里面的内容进行查看：
[root@bhDocker216 8a1e3ad05d9e66a455e***]# ls
container.json  state.json
</code></pre>
###- volumes
没有加-v参数的volumes是空的，经测试如果启动容器增加加-v参数，volumes文件夹下将显示一个UUID，在host进行全局搜索，只在volumes下找到了，跟镜像和容器的UUID都没有关系。
<pre><code>
[root@bhDocker216 docker]# find / -name 86eb77f9f5e25676f100***d5a
/var/lib/docker/volumes/86eb77f9f5e25676f100***d5a
//查看里面的内容：
[root@bhDocker216 volumes]# ls 86eb77f9f5e25676f100***d5a
config.json
[root@bhDocker216 volumes]# cat 86eb77f9f5e25676f100***d5a /config.json 
{"ID":"86eb77f9f5e25676f100a89ba727bc15185303236aae0dcf4c17223e37651d5a","Path":"/home/data","IsBindMount":true,"Writable":true}
</code></pre>
#文件夹作用表格性说明
做个总结，整理一个表格，把/var/lib/docker下的不同文件夹作用说明下：


/var/lib/docker/文件夹|作用
:---------------|:---------------
containers|运行的容器的UUID，UUID文件夹放容器在启动前和启动时（参数）的配置
repositories-devicemapper|本地上存放的镜像的名称及其64位长度的ID即：IMAGENAME：TAG，UUID；docker images 查看到的信息 
graph|layer image的相关信息，不是镜像的内容；dokcer images -tree查看到的信息
devicemapper/devicemapper|data：镜像和容器文件存储地
devicemapper/metadata|小的json文件，跟踪快照的ID和大小
execdriver/native/|运行container的UUID，里面存储了container.json和state.json；通过docker ps –a查看
volumes|添加-v参数后生成一个UUID文件夹，里面是具体的共享卷配置信息



更多关于docker的技术文章，请访问：[team blog](http://openstack.wiaapp.cn/)
