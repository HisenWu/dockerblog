#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker create container" {
        start_docker 2
        swarm_manage
        #create
        run docker_swarm create --name test_container busybox sleep 1000
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"test_container"* ]]
}

@test "docker start container" {
        start_docker 2
        swarm_manage
        #create
        run docker_swarm create --name test_container busybox sleep 1000
        [ "$status" -eq 0 ]
        #start
        run docker_swarm start test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Up"* ]]
}

@test "docker stop container" {
        start_docker 2
        swarm_manage
        #run 
        run docker_swarm run --name test_container busybox sleep 1000
        [ "$status" -eq 0 ]
        #stop
        run docker_swarm stop test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Exited"* ]]
}
@test "docker restart container" {
        start_docker 2
        swarm_manage
        #run 
        run docker_swarm run --name test_container busybox sleep 1000
        [ "$status" -eq 0 ]
        #restart
        run docker_swarm restart test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Up"* ]]
}

@test "docker kill container" {
        start_docker 2
        swarm_manage
        #run 
        run docker_swarm run --name test_container busybox sleep 1000
        [ "$status" -eq 0 ]
        #kill
        run docker_swarm kill test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Exited"* ]]
}

