#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker delete container" {
        start_docker 1
        swarm_manage
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]
        
        #rm -f
        run docker_swarm rm -f test_container
        [ "$status" -eq 0 ]
        
        #verify
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 1 ]
}
