#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker run container" {
	start_docker 3
	swarm_manage
	
	# run after 10 seconds, test_container will exit
	run docker_swarm run -d --name test_container busybox sleep 10
	[ "$status" -eq 0 ]
	
	# make sure container exists and is up
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" ==  *"test_container"* ]]
	[[ "${lines[1]}" ==  *"Up"* ]]
	
	# wait until exist
	run docker_swarm wait test_container
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 1 ]
	[[ "${lines[0]}" == "0" ]]
}
