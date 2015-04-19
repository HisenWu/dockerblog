#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker logs should prensent at the time of execution" {
	start_docker 3
	swarm_manage
	
	# run a container with echo command
	run docker_swarm run -d --name test_container busybox echo hello world
	[ "$status" -eq 0 ]
	# make sure container exists
	run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"test_container"* ]]
	
	# verify
	run docker_swarm logs test_container
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 1 ]
        [[ "${lines[0]}" ==  *"hello world"* ]]
}
