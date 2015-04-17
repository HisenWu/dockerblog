#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker delete container" {
        start_docker 3
        swarm_manage
        run docker_swarm run -d --name test_container busybox
        [ "$status" -eq 0 ]
        
        # make sure the delete container is exsist and exited
        run docker_swarm ps -a
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[*]}" == *"Exited"* ]]
        
        run docker_swarm rm test_container
        [ "$status" -eq 0 ]
        
        # verify
        run docker_swarm ps -a
        [ "${#lines[@]}" -eq 1 ]
}
