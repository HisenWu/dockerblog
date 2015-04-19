
#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker tag image" {
	start_docker 3
	swarm_manage
	
	run docker_swarm pull busybox
	[ "$status" -eq 0 ]
	
	# make sure the image of busybox exists
	run docker_swarm images -q
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"busybox"* ]]
	
	# tag image
	run docker_swarm tag busybox tag_busybox:test
	[ "$status" -eq 0 ]
	
	# cluster refresh the state of image need 30 seconds
	# sleep 35
	# verify
	run docker_swarm images -q
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"tag_busybox"* ]]
}
