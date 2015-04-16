#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker rename" {
        #create
        start_docker 1
        swarm_manage
        
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]

        ##rename container
        run docker_swarm rename test_container rename_container
        [ "$status" -eq 0 ]

        ##vertify after rename 
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"rename_container"* ]]
}
