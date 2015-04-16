#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker delete container" {
        start_docker 1
        swarm_manage
        run docker_swarm run -d --name test_container -v /home:/home busybox sleep 500
        [ "$status" -eq 0 ]
        
        #make sure volume
        run docker_swarm inspect --format='{{.Volumes}}' test_container
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"/home:/home"* ]]
        
        #rm -v
        run docker_swarm rm -v test_container
        [ "$status" -eq 0 ]
        
        #verify
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 1 ]
}
