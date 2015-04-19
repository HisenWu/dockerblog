
#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm image" {
	start_docker 3
	swarm_manage
	
	# make sure no image exist
	run docker_swarm images -q
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 1 ]
	
	# pull image
	run docker_swarm pull busybox
	[ "$status" -eq 0 ]
	
	# verify image
	run docker_swarm images -q
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"busybox"* ]]
}
