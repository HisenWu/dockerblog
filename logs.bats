#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test " docker logs should prensent at the time of execution" {
        start_docker 1
        swarm_manage
        
        #run a container
        run docker_swarm run -d --name logs_container ubuntu:latest sleep 100
        [ "$status" -eq 0 ]
        
        #make sure container is up
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Up"* ]]

        run docker_swarm logs logs_container
        [ "$status" -eq 0 ]
}
