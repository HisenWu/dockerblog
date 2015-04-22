#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker cp container" {
	start_docker 3
	swarm_manage
	
	test_file="/bin/busybox"
	# create a temporary destination directory
	temp_dest=`mktemp -d`
	
	# create the container
	run docker_swarm run -d --name test_container busybox sleep 500
	[ "$status" -eq 0 ]
	
	# make sure container is up and no comming file
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" == *"Up"* ]]
	
	# grab the checksum of the test file inside the container.
	run docker_swarm exec test_container md5sum $test_file
	[ "$status" -eq 0 ]
	container_checksum=$output
	[ ! -f $temp_dest/`basename $test_file` ]
	
	# copy the test file from the container to the host.
	run docker_swarm cp $container_id:$test_file $temp_dest
	[ "$status" -eq 0 ]
	[ -f $temp_dest/`basename $test_file` ]
	
	# compute the checksum of the copied file.
	run md5sum $temp_dest/`dirname $test_file`
	[ "$status" -eq 0 ]
	host_checksum=$output
	
	# Verify that they match.
	[ $container_checksum == $host_checksum ]
	
	rm -f $temp_dest/`basename $test_file`
}
