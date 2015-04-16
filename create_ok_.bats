#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm create/start/stop container should return success" {
        start_docker 2
        swarm_manage
        run docker_swarm create --name create_container busybox sleep 1000
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"create_container"* ]]

        #start
        run docker_swarm start create_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Up"* ]]

        #stop
        run docker_swarm stop create_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Exited"* ]]

        #restart
        run docker_swarm restart create_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Up"* ]]

        #kill
        run docker_swarm kill create_container
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Exited"* ]]
}
        
  }
