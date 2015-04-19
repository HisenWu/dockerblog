
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
	# the comming image of tag_busybox not exsit
	run docker_swarm images -q
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"busybox"* ]]
	[[ "${lines[*]}" != *"tag_busybox"* ]]
	
	# tag image
	run docker_swarm tag busybox tag_busybox:test
	[ "$status" -eq 0 ]

	# verify
	run docker_swarm images -q
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"tag_busybox"* ]]
}
