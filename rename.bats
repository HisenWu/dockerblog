#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker rename: rename a container's name should return success" {
        #create
        start_docker 1
        swarm_manage
        
        run docker_swarm run -d --name running_container ubuntu:latest sleep 100
        [ "$status" -eq 0 ]

        ##rename container
        run docker_swarm rename running_container rename_container
        [ "$status" -eq 0 ]

        ##vertify after rename 
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"rename_container"* ]]
}
