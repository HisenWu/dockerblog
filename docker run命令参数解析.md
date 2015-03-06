详解docker存储驱动
----
目的

* 理解docker的存储方式
* docker的image和container在host上的目录结构
* docker image和container的内容与配置不同存储

Docker是一个开源的应用容器引擎，主要利用Linux内核namespace实现沙盒隔离，用Cgroup实现资源限制。Docker用于统一开发和部署的轻量级 Linux 容器，试图解决“依赖地狱”问题，把依赖的服务和组件组合起来，类似船舶使用的集装箱，达到快速安装部署。

#1. Docker的基本架构---Client和Daemon
让我们先搞明白docker的基本架构和启动过程，其实Docker 采用了C/S架构，包括客户端和服务端。Docker daemon作为服务端接受来自客户的请求，并处理这些请求（创建、运行、提交容器）。 客户端和服务端在一个机器上，通过RESTful API 来进行通信。

具体到使用的过程中，就是在执行service docker start后，在主机（host）上产生docker deamon守护进程，在后台运行并等待接收来自客户端的消息（即输入的docker命令，如docker pull xxx，docker run …，docker commit xxx），实现跟docker deamon的交互。当启动docker服务后，可以看到docker进程。
<pre><code>[root@localhost ~]# ps -aux | grep docker
root     11701  0.0  0.4 359208 16624 ?        Ssl  21:05   0:00 /usr/bin/docker -d -H fd:// --selinux-enabled --insecure-registry 186.100.8.216:5000
root     11861  0.0  0.0 113004  2256 pts/0    S+   23:01   0:00 grep --color=auto docker
</code></pre>
