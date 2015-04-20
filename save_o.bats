#!/usr/bin/env bats

load helpers

function teardown(){
	swarm_manage_cleanup
	stop_docker
}

@test "docker save image" {
	start_docker 3
	swarm_manage
	
	run docker_swarm pull busybox
	[ "$status" -eq 0 ]
	
	# make sure busybox image exists and no comming file in current path
	run docker_swarm images -q
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"busybox"* ]]
	[ ! -f save_busybox_image_oupt.tar ]
	
	# save -o, image->tar
	run docker_swarm save -o save_busybox_image_oupt.tar busybox 
	[ "$status" -eq 0 ]
	
	# saved image tar file exists
	[ -f save_busybox_image_oupt.tar ]
	
	# after ok, delete saved tar file
	rm -f save_busybox_image_oupt.tar
}
