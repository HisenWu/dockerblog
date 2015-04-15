#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker attach: attach to a running container" {
        #create
        start_docker 1
        swarm_manage
        run docker_swarm run -d --name running_container ubuntu:latest sleep 60
        [ "$status" -eq 0 ]
        ##container is up
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"Up"* ]]
        run docker_swarm attach running_container sleep 60
        [ "$status" -eq 0 ]
}
