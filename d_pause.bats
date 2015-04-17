#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker pause a running container" {
	start_docker 3
	swarm_manage
	
	run docker_swarm run -d --name test_container busybox sleep 1000
	[ "$status" -eq 0 ]
	
	# make sure container is up
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" == *"Up"* ]]
	
	run docker_swarm pause test_container
	[ "$status" -eq 0 ]
	
	# verify
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" == *"Paused"* ]]
}
