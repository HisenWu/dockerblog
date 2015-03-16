###Registry
Registry存储镜像数据，并且提供拉取和上传镜像的功能。      
Registry中镜像是通过Repository来组织的，而每个Repository又包含了若干个Image。

* Registry包含一个或多个Repository
* Repository包含一个或多个Image
* Image用GUID表示，有一个或多个Tag与之关联

###Docker Engine指的是容器的运行时环境
###我们创建了一个 容器 (~相当于一个轻量级的虚拟机), 
它拥有:
* 文件系统 (基于一个 python 镜像)
* 网络栈（network stack）
* 进程空间    
    
###没有对'python'镜像进行完整地拷贝，我们仅仅是`跟踪 容器 相对于 镜像`所发生的变化
     
###安装过程在 容器 中完成, 而并非是在 镜像 中完成
     
###Overly与AUFS很类似，只有很少的地方有差别:
* 只有两个分支only two branches (被称为文件层("layers"))
* 但是分支只能进行自我覆盖
###Docker Hub服务相关
* login
* pull / push
* search
      
###Docker后台进程是一个常驻后台的系统进程。     
值得注意的是：Docker使用同一个文件来支持客户端和后台进程，其中角色切换通过-d来实现。

###libcontainer
Docker从一开始就是围绕LXC开发的，但在版本稳定后，使用Go重写了一套`类LXC接口`实现。也就是 libcontainer 项目。 它的代码管理方式与上面的Docker源代码管理方式一样，开发者可以很容易的导入到子项目libcontainer的开发。         一致的管理方法可以提高流程的复用，这种管理方式希望能得到大家的借鉴参考。     
------
###实战
####开发人员的开发环境，复杂的配置和重复的下载安装，docker解决？
>Image或Dockerfile，复用开发环境
>Docker Hub搜索、下载常用的开发环境Image
Docker的集成测试部署方法，并结合众场景（数据库集成、测试、审查、部署）给出参考解决方案      
* 践行敏捷开发所提倡的以人为中心、迭代、循序渐进的开发理念
* 使用Docker提供的虚拟化方式，给开发团队建立一套可以复用的开发环境，让开发环境可以通过Image的形式分享给项 目的所有开发成员，以简化开发环境的搭建
* Docker的优点在于可以简化CI（持续集成）、 CD（持续交付）的构建流程，让开发者把更多的精力用在开发上
* Base Image包括了操作系统命令行和类库的最小集合，一旦启用，所有应用都需要以它为基础创建应用镜像。
* 结合Docker的开发部署工具Fig，我们可以使用fig.yml文件来定义所有的环境，一次定义，多处使用，简单而且高效。
