
[oh](http://dockerone.com/question/160)                       

其实这些[官方doc](https://docs.docker.com/)都有介绍。

###Machine：
解决的是操作系统异构安装Docker困难的问题，没有Machine的时候，CentOS是一种，Ubuntu又是一种，AWS又是一种。                 
**有了Machine，所有的系统都是一样的安装方式。**

###Swarm：
我们有了Machine就意味着有了docker环境，但是那是单机的，而通常我们的应用都是集群的。                        
这正是Swarm要做的事情，给你**提供docker集群环境和调度策略等。**

###Compose：
有了环境，我们下一步要做什么？部署应用啊。                     
然后我们需要docker run image1、docker run image2...一次一次不厌其烦的重复这些操作，每次都写大量的命令参数。                       
**Compose简化部署应用流程，只需要把命令参数固化到docker-compose.yml中。**

目前Machine、Swarm、Compose已经可以结合使用，创建集群环境，简单的在上面部署应用。              
但是还不完善，比如对于有link的应用，它们只能跑在Swarm集群的一个机器上，即使你的集群有很多机器。            
[可以参考另一个问题。](http://dockerone.com/question/105)

###SocketPlane
Docker最近收购的产品，猜想应该是为了**强化Docker的网络功能**，           
比如提供原生跨主机的网络定制、强化Swarm和Compose的结合等。
