#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm create/start/stop container should return success" {
        
        start_docker 1
        swarm_manage
        
        #create
        run docker_swarm create --name test_container busybox sleep 1000
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 2 ]
        [[ "${#lines[1]}" ==  *"test_container"* ]]

        #start
        run docker_swarm start test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 2 ]
        [[ "${#lines[1]}" ==  *"Up"* ]]

        #stop
        run docker_swarm stop test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${#lines[1]}" ==  *"Exited"* ]]

        #restart
        run docker_swarm restart test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 2 ]
        [[ "${#lines[1]}" ==  *"Up"* ]]

        #kill
        run docker_swarm kill test_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 2 ]
        [[ "${#lines[1]}" ==  *"Exited"* ]]
  }
