```shell
✗ etcd discovery should be working correctly
   (from function `wait_until_reachable' in file helpers.bash, line 36,
    from function `swarm_manage' in file helpers.bash, line 50,
    in test file etcd-discovery.bats, line 30)
     `swarm_manage etcd://${ETCD_HOST}/test' failed
   Unable to find image 'microbox/etcd:latest' locally
   Pulling repository microbox/etcd
   b3a779fd9563: Pulling image (latest) from microbox/etcd
   b3a779fd9563: Pulling image (latest) from microbox/etcd, endpoint: https://registry-1.docker.io/v1/
   b3a779fd9563: Pulling dependent layers
   5538e17302b5: Pulling metadata
   5538e17302b5: Pulling fs layer
   5538e17302b5: Download complete
   f5de5ff07f23: Pulling metadata
   f5de5ff07f23: Pulling fs layer
   f5de5ff07f23: Download complete
   0ad8b136dd50: Pulling metadata
   0ad8b136dd50: Pulling fs layer
   0ad8b136dd50: Download complete
   2933f564adf2: Pulling metadata
   2933f564adf2: Pulling fs layer
   2933f564adf2: Download complete
   b3a779fd9563: Pulling metadata
   b3a779fd9563: Pulling fs layer
   b3a779fd9563: Download complete
   b3a779fd9563: Download complete
   Status: Downloaded newer image for microbox/etcd:latest
   723a22c08375bc27150676536b0086c112b1e8c195850cc90a6a880b5457e5af
   Containers: 0
   Images: 0
   Storage Driver: aufs
    Root Dir: /var/lib/docker/aufs
    Backing Filesystem: extfs
    Dirs: 0
   Execution Driver: native-0.2
   Kernel Version: 3.16.0-23-generic
   Operating System: Ubuntu 14.04.1 LTS (containerized)
   CPUs: 1
   Total Memory: 993.5 MiB
   Name: node-0
   ID: O6IW:J2OU:WV3A:T5DY:GXCK:77P3:GH5Z:TIJR:IWBU:72OK:WM6O:EHLL
   WARNING: No swap limit support
   Containers: 0
   Images: 0
   Storage Driver: aufs
    Root Dir: /var/lib/docker/aufs
    Backing Filesystem: extfs
    Dirs: 0
   Execution Driver: native-0.2
   Kernel Version: 3.16.0-23-generic
   Operating System: Ubuntu 14.04.1 LTS (containerized)
   CPUs: 1
   Total Memory: 993.5 MiB
   Name: node-1
   ID: PT43:PEC2:O7D7:P7DB:2NRF:FCRU:GRD6:SMYK:HNTH:AXUB:2VXP:GA67
   WARNING: No swap limit support
   Containers: 0
   Images: 0
   Storage Driver: aufs
    Root Dir: /var/lib/docker/aufs
    Backing Filesystem: extfs
    Dirs: 0
   Execution Driver: native-0.2
   Kernel Version: 3.16.0-23-generic
   Operating System: Ubuntu 14.04.1 LTS (containerized)
   CPUs: 1
   Total Memory: 993.5 MiB
   Name: node-2
   ID: 5YSE:GFFS:JVCZ:5QCC:3U3S:RIGT:ASEC:T2XL:KSDR:7R2Z:LLXT:SKRL
   WARNING: No swap limit support
   time="2015-04-22T12:00:09+08:00" level=info msg="Listening for HTTP" addr="127.0.0.1:6298" proto=tcp 
   time="2015-04-22T12:00:09+08:00" level=fatal msg="501: All the given peers are not reachable (Tried to connect to each peer twice and failed) [0]" 
   time="2015-04-22T12:00:09+08:00" level="fatal" msg="Cannot connect to the Docker daemon. Is 'docker -d' running on this host?" 
   Attempt to connect to 127.0.0.1:5836 failed for the 1 time
   time="2015-04-22T12:00:10+08:00" level="fatal" msg="Cannot connect to the Docker daemon. Is 'docker -d' running on this host?" 
   Attempt to connect to 127.0.0.1:5836 failed for the 2 time
   time="2015-04-22T12:00:10+08:00" level="fatal" msg="Cannot connect to the Docker daemon. Is 'docker -d' running on this host?" 
   Attempt to connect to 127.0.0.1:5836 failed for the 3 time
   time="2015-04-22T12:00:11+08:00" level="fatal" msg="Cannot connect to the Docker daemon. Is 'docker -d' running on this host?" 
   Attempt to connect to 127.0.0.1:5836 failed for the 4 time
   time="2015-04-22T12:00:11+08:00" level="fatal" msg="Cannot connect to the Docker daemon. Is 'docker -d' running on this host?" 
   Attempt to connect to 127.0.0.1:5836 failed for the 5 time
   time="2015-04-22T12:00:12+08:00" level="fatal" msg="Cannot connect to the Docker daemon. Is 'docker -d' running on this host?" 
   /usr/share/gocode/src/github.com/docker/swarm/test/integration/helpers.bash: line 84: kill: (23505) - No such process
   Stopping 22dc6b0b61e18e8fb3f8d6270c3b8ab8878d60f3da08d6188cd08e8009b86455
   Stopping 8640bb98f881bd484d069c30be4fa4fc309f4b03682a239ea29ea0a46f7890d4
   Stopping d5b057f2328e2584279bc35472789b4902aee34a6f1a051abf6caa86eb99ef7a
```
