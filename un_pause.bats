#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker pause a running container should return success" {
        start_docker 1
        swarm_manage
        
        run docker_swarm run -d --name exec_container ubuntu:latest sleep 100
        [ "$status" -eq 0 ]
        
        #make sure container is up
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"Up"* ]]
        
        #pause
        run docker_swarm pause exec_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"Paused"* ]]
        
        #unpause
        run docker_swarm unpause exec_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" !=  *"Paused"* ]]
}
