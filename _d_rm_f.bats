#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker rm -f" {
	start_docker 3
	swarm_manage
	
	run docker_swarm run -d --name test_container busybox sleep 500
	[ "$status" -eq 0 ]
	
	# make sure container exsists and is up
	run docker_swarm ps -a
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" == *"test_container"* ]]
	[[ "${lines[1]}" == *"Up"* ]]
	
	# rm -f, remove a running container
	run docker_swarm rm -f test_container
	[ "$status" -eq 0 ]
	
	# verify
	run docker_swarm ps -aq
	[ "${#lines[@]}" -eq 0 ]
}
