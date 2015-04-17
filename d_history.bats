#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker history" {
        start_docker 3
        swarm_manage
        
        # pull busybox image
        run docker_swarm pull busybox
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"busybox"* ]]
        
        # history
        run docker_swarm history busybox
        [ "$status" -eq 0 ]
        [[ "${lines[0]}" == *"CREATED BY"* ]]
}
        
        
