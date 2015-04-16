#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker kill container" {
        start_docker 2
        swarm_manage
        #run 
        run docker_swarm run --name test_container busybox sleep 1000
        [ "$status" -eq 0 ]
        #make sure container is up
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Up"* ]]
        #kill
        run docker_swarm kill test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Exited"* ]]
}
