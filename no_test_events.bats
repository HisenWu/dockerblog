#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker events" {
	TEMP_FILE=$(mktemp)
	start_docker 3
	swarm_manage
	
	# start events, report real time events to TEMP_FILE
	run docker_swarm events > $TEMP_FILE &
	
	# events: create container
	run docker_swarm create --name test_container busybox sleep 100 
	[ "$status" -eq 0 ]
	# events: start container
	run docker_swarm start test_container
	[ "$status" -eq 0 ]
	
	# make sure $TEMP_FILE exists and is not empty
	[ -s $TEMP_FILE ]
	
	# verify
	run cat $TEMP_FILE
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[0]}" == *"create"* ]]
	[[ "${lines[1]}" == *"start"* ]]
}
