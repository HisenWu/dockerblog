#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker search" {
        start_docker 3
        swarm_manage

        #search image
        run docker_swarm search no_this_image
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"DESCRIPTION"* ]]
        
        run docker_swarm search busybox
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"busybox"* ]]
}
