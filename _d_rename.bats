#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker rename" {
        start_docker 3
        swarm_manage
        
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]

        # rename container
        run docker_swarm rename test_container rename_container
        [ "$status" -eq 0 ]
        # make sure container exist
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[*]}" == *"test_container"* ]]
        [[ "${lines[*]}" != *"rename_container"* ]]
        
        # cluster refresh the state of container need 30 seconds  (--filter ?)
        # sleep 35
        
        # verify after rename 
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[*]}" == *"rename_container"* ]]
}
