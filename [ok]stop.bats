#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker stop container" {
        start_docker 2
        swarm_manage
        #run 
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]
        #stop
        run docker_swarm stop test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" == *"Exited"* ]]
}


