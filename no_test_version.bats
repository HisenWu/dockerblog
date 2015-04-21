#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker version" {
	start_docker 3
	swarm_manage

	# version
	run docker_swarm version
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 9 ]
	[[ ${lines[0]} =~ Client version:\ [0-9]+\.[0-9]+\.[0-9]+ ]]
	[[ ${lines[5]} =~ Server version:\ [0-9]+\.[0-9]+\.[0-9]+ ]]
}
