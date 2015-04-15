#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm delete container should return success" {
        start_docker 1
        swarm_manage
        run docker_swarm run -d --name delete_container busybox sleep 60
        [ "$status" -eq 0 ]
        
        #make sure the delete container is exsist
        run docker_swarm ps -l
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"delete_container"* ]]
        
        run docker_swarm rm delete_container
        [ "$status" -eq 0 ]
}
