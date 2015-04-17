#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker diff container" {
        start_docker 1
        swarm_manage
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]

        ##make sure container is up
        run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"Up"* ]]
		
	#make diff
        run docker_swarm exec test_container touch /home/diff.txt
        [ "$status" -eq 0 ]
        
        run docker_swarm diff test_container
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" ==  *"diff.txt"* ]]
}
