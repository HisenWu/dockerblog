#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker cp container" {
        start_docker 1
        swarm_manage
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]

        ##make sure container is up
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Up"* ]]
		
	#touch cp file
        run docker_swarm exec test_container touch /home/cp.txt
        [ "$status" -eq 0 ]
        
        run docker_swarm cp test_container:/home/cp.txt /tmp/
        [ "$status" -eq 0 ]
        [ -f "/tmp/cp.txt" ]
}
