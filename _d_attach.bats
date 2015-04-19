#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker attach to a running container" {
        start_docker 3
        swarm_manage
        
        # container run in background
        run docker_swarm run -d --name test_container busybox sleep 100
        [ "$status" -eq 0 ]

        # make sure container is up
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Up"* ]]

        run docker_swarm attach test_container
        [ "$status" -eq 0 ]
}
