#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker create container" {
        start_docker 2
        swarm_manage
        #create
        run docker_swarm create --name test_container busybox sleep 1000
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"test_container"* ]]
}
