(转)5个解决Docker网络问题的项目
----
Docker 是一个开源的应用容器引擎，它可以让开发者将自己的应用以及应用所依赖的内容打包到一个可移植的容器中，然后将该容器发布到任何流行的 Linux 机器上，也可以实现虚拟化。Docker 彻底释放了虚拟化的威力，它让应用的分发、部署和管理都变得前所未有的高效和轻松，凭借着自己出众的能力，Docker现在已经成为目前IT界创业者和创新者的宠儿。那么Docker是否已经足够完美了呢？答案当然是否定的，对于管理者和开发人员来说网络依然是Docker的一个痛点，如何管理Docker容器之间的交互和网络一直都充满了挑战。


为了解决网络的问题，有很多公司都开发了各自的产品以帮助开发者更方便地使用Docker。Serdar Yegulalp最近在InfoWorld上分享了一篇文章，介绍了这些项目中最重要的5个，包括Weave、Kubernetes、CoreOS, Flannel、Pipework以及SocketPlane，同时他认为这其中的部分项目将来可能会成为Docker的组成部分。下面就让我们来了解一下这5个项目。


**Weave**是由Zett.io公司开发的，它能够创建一个虚拟网络来连接部署在多台主机上的Docker容器。通过Weave所有的容器就像被接入了同一个网络交换机，那些使用网络的应用程序不必去配置端口映射和链接等信息。外部设备能够访问Weave网络上的应用程序容器所提供的服务，同时已有的内部系统也能够暴露到应用程序容器上。Weave能够穿透防火墙并运行在部分连接的网络上。另外，Weave的通信支持加密，所以用户可以从一个不受信任的网络连接到主机。如果你想了解更多与Weave相关的信息，或者查看相关源码，那么可以点击这里。   

**Kubernetes**是由Google推出的针对容器管理和编排的开源项目，它让用户能够在跨容器主机集群的情况下轻松地管理、监测、控制容器化应用部署。Kubernete有一个特殊的与SDN非常相似的网络化概念：通过一个服务代理创建一个可以分配给任意数目容器的IP地址，前端的应用程序或使用该服务的用户仅通过这一IP地址调用服务，不需要关心其他的细节。这种代理方案有点SDN的味道，但是它并不是构建在典型的SDN的第2-3层机制之上。如果对此感兴趣可以阅读一下Craig Matsumoto在sdncentral上发表的这篇文章，或者点此查看源码。   

**Flannel**之前的名字是Rudder，它是由CoreOS团队针对Kubernetes设计的一个覆盖网络工具，其目的在于帮助每一个使用 Kuberentes 的 CoreOS 主机拥有一个完整的子网。Kubernetes 会为每一个 POD 分配一个独立的 IP 地址，这样便于同一个 POD 中的Containers 彼此连接，而之前的 CoreOS 并不具备这种能力。为了解决这一问题，Flannel 通过在集群中创建一个覆盖网络为主机设定一个子网。点此查看该项目的源码。    

**Pipework**是由Docker的一个工程师设计的解决方案，它让容器能够在“任意复杂的场景”下进行连接。Pipework是Docker的一个网络功能增强插件，它使用了cgroups和namespacpace。点此查看该项目的源码。


**SocketPlane**目前仅停留在将“SDN带给Docker”的口号上，基本上没有实质性的工作。该项目的想法是使用和部署Docker一样的devops工具管理容器的虚拟化网络，同时为Docker构建一个相当于OpenDaylight/Open vSwitch的产品。听起来非常有前途，但是在2015年一季度之前我们无法看到任何产品。

另外,[一个论坛的讨论](http://bbs.chinaunix.net/thread-4170956-1-1.html)：      

Docker 官方宣布收购 SocketPlane 多主机容器网络解决方案。现在 SocketPlane 加入 Docker 显然将会大大促进了 Docker 的进一步发展。   

开发者不想操作是否是 VLANs, VXLANs, Tunnels 或者是 TEPs. 对于架构人们最关心的是性能和可靠性。而 SocketPlane 在 socket 层面提供了一个网络的抽象层，通过可管理的方式去解决各种网络问题。   


**SocketPlane 主要特性：**  

1、Open vSwitch 集成；   

2、用于 Docker 的零配置多主机网络；    

3、Docker/SocketPlane 集群的优雅增长；    

4、支持多网络；    

5、分布式 IP 地址管理 (IPAM)。   

  

**讨论话题**   

1、大家如何理解DOCKER。     

2、在实际的应用部署中DOCKER存在的优点和缺点。     

3、DOCKER集群系统部署的技术要点和资源管理方式。
