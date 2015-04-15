#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker top: display the running processes of a container" {
        #create
        start_docker 1
        swarm_manage
        
        run docker_swarm run -d --name running_container ubuntu:latest sleep 100
        [ "$status" -eq 0 ]
        #make sure container is running
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"Up"* ]]
        
        run docker_swarm top running_container
        [ "$status" -eq 0 ]
        [[ "${#lines[0]}" ==  *"UID"* ]]
}
