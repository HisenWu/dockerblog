#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker run container" {
	start_docker 3
	swarm_manage
	
	# run after 10 seconds, test_container will exit
	run docker_swarm run -d --name test_container busybox sleep 3
	[ "$status" -eq 0 ]
	
	# make sure container exists and is up
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" ==  *"test_container"* ]]
	[[ "${lines[1]}" ==  *"Up"* ]]
	
	# wait until exist
	run docker_swarm wait test_container &
	WAIT_PID=$!
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 1 ]
	[[ "${lines[0]}" == "0" ]]
	
	sleep 3
	kill -9 $WAIT_PID
	
	
}


# Spawn a child process:
(dosmth) & pid=$!
# in the background, sleep for 10 secs then kill that process
(sleep 10 && kill -9 $pid) &
or to get the exit codes as well:

# Spawn a child process:
(dosmth) & pid=$!
# in the background, sleep for 10 secs then kill that process
(sleep 10 && kill -9 $pid) & waiter=$!
# wait on our worker process and return the exitcode
exitcode=$(wait $pid && echo $?)
# kill the waiter subshell, if it still runs
kill -9 $waiter 2>/dev/null
# 0 if we killed the waiter, cause that means the process finished before the waiter
finished_gracefully=$?


