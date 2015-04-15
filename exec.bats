#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test " docker exec which runs command inside the running container should return success" {
        start_docker 1
        swarm_manage
        
        run docker_swarm run -d --name exec_container ubuntu:latest sleep 100
        [ "$status" -eq 0 ]
        
        #make sure container is up
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"Up"* ]]
        
        run docker_swarm exec exec_container ls
        [ "$status" -eq 0 ]
}
