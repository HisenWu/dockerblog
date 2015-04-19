
#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm image" {
	start_docker 3
	swarm_manage

	run docker_swarm run -d --name test_container busybox 
	[ "$status" -eq 0 ]
	
	# make sure container exists
	run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"test_container"* ]]
	
	# create untagged image
	run docker_swarm commit test_container
	[ "$status" -eq 0 ]
	
	# make sure exist untagged image
	run docker_swarm images -q
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"none"* ]]
	
	# images --filter
	run docker_swarm images --filter "dangling=true" -q
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"none"* ]]
}
