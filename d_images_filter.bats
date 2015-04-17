
#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm image" {
	start_docker 3
	swarm_manage
	
	# create untagged image
	run docker_swarm run -d --name test_container busybox 
	[ "$status" -eq 0 ]
	run docker_swarm commit test_container
	[ "$status" -eq 0 ]
	
	# images --filter
	run docker_swarm images --filter "dangling=true"
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"none"* ]]
}
