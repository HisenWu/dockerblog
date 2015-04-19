#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker start container" {
        start_docker 1
        swarm_manage
        # create
        run docker_swarm create --name test_container busybox sleep 1000
        [ "$status" -eq 0 ]
        
        # make sure create container exist
        # new container created has no status
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        
        # start
        run docker_swarm start test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Up"* ]]
}
