#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test " docker exec run inside the running container" {
        start_docker 1
	swarm_manage
	run docker_swarm run -d --name test_container busybox sleep 100
	[ "$status" -eq 0 ]
	
	##make sure container is up and not paused
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq  2 ]
	[[ "${lines[1]}" == *"Up"* ]]
	[[ "${lines[1]}" != *"Paused"* ]]

        run docker_swarm exec test_container ls
        [ "$status" -eq 0 ]
}
