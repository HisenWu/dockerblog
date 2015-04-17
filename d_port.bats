#!/usr/bin/env bats

load helpers

function teardown(){
	swarm_manage_cleanup
	stop_docker
}

@test " docker port the running container" {
	start_docker 3
	swarm_manage
	run docker_swarm run -d -p 8000 --name test_container busybox sleep 500
	[ "$status" -eq 0 ]
	
	#make sure container is up
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq  2 ]
	[[ "${lines[1]}" == *"Up"* ]]
	
	run docker_swarm port test_container
	[[ "${lines[*]}" == *"8000"* ]]
}
