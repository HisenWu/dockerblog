#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker load should return success, every node should load the image" {
        start_docker 1
        swarm_manage
        run docker_swarm pull busybox 
        [ "$status" -eq 0 ]
        
        #docker_swarm verify
        run docker_swarm images
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"busybox"* ]]
        
        #node verify
        run docker -H  ${HOSTS[0]} images
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq  2 ]
}
