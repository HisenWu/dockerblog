#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker export contanier" {
        start_docker 1
        swarm_manage
        #run a container to export
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]
        run docker_swarm export test_container > container_busybox.tar
        [ "$status" -eq 0 ]
        #exported file exists
        [ -f container_busybox.tar ]
        
        #ater ok, delete tar file
        rm -f container_busybox.tar
}
