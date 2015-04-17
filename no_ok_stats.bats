#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker show contianer stats" {
        start_docker 1
        read A
        swarm_manage
        #stats running container 
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]

        #make sure container is up
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" == *"Up"* ]]

        run docker_swarm stats test_container &
        STATS_PID=$!
        [ "$status" -eq 0 ]
        sleep 1
        kill -SIGSTOP STATS_PID
        [[ "${lines[0]}" == *"CPU %"* ]]
}
