#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker logs should prensent at the time of execution" {
        start_docker 1
        swarm_manage
        
        # run a container
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]
        
        run docker_swarm logs test_container
        [ "$status" -eq 0 ]
}
