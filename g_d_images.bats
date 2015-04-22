
#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm image" {
	start_docker 3
	swarm_manage
	
	# no image exist
	run docker_swarm images -q
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 0 ]
	
	# make sure every node has no image
	for((i=0;i<3;i++)); do
		run docker_swarm images --filter node=node-$i -q
		[ "$status" -eq 0 ]
		[ "${#lines[@]}" -eq 0 ]
	done
	
	# pull image
	run docker_swarm pull busybox
	[ "$status" -eq 0 ]
	
	# make sure images have pulled
	run docker_swarm images
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -ge 4 ]
	for((i=1; i<${#lines[@]}; i++)); do
		[[ "${lines[i]}" == *"busybox"* ]]
	done

	# verify
	for((i=0; i<3; i++)); do 
		run docker_swarm images --filter node=node-$i
		[ "$status" -eq 0 ]
		[ "${#lines[@]}" -ge 2 ]
		[[ "${lines[1]}" == *"busybox"* ]]
	done
}
