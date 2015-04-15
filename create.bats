#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm create/start/stop container should return success" {
        #create
        start_docker 1
        swarm_manage
        ##need option -i -t
        run docker_swarm create -i -t --name create_container ubuntu:latest sleep 60
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"create_container"* ]]

        #start
        run docker_swarm start create_container sleep 10
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"Up"* ]]

        #stop
        run docker_swarm stop create_container sleep 10
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"Exited (0)"* ]]

        #restart
        run docker_swarm restart create_container sleep 40
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
        [[ "${#lines[@]}" -eq 2 ]]
        [[ "${#lines[1]}" ==  *"Up"* ]]

        #kill
        run docker_swarm kill create_container sleep 10
        [ "$status" -eq 0 ]
        run docker_swarm ps -l
  }
