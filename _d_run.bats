#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker run container" {
	start_docker 3
	swarm_manage
	
	# make sure not exist containers
        run docker_swarm ps -qa
        [ "${#lines[@]}" -eq 0 ]
	
	# run
	run docker_swarm run -d --name test_container busybox sleep 100
	[ "$status" -eq 0 ]
	
	# verify, container exists
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[*]}" == *"test_container"* ]]
}
