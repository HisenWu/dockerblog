#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker rm -v" {
	start_docker 3
	swarm_manage
	run docker_swarm run -d --name test_container -v /tmp:/data busybox
	[ "$status" -eq 0 ]
	# make sure container exsists
	run docker_swarm ps -a
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" == *"test_container"* ]]
	
	# make sure mount a volume
	run docker_swarm inspect --format='{{.Volumes}}' test_container
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"/tmp:/data"* ]]

	# rm -v (if container is up, add -f)
	run docker_swarm rm -v test_container
	[ "$status" -eq 0 ]
	
	# verify
	run docker_swarm ps -a
	[ "${#lines[@]}" -eq 1 ]
}
