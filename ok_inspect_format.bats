#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker inspect container" {
        start_docker 3
        swarm_manage
        # run container
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]
        
        # make sure container exsists
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" == *"test_container"* ]]
	
        # inspect --format='{{.Config.Image}}', return one line: image name
        run docker_swarm inspect --format='{{.Config.Image}}' test_container
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 1 ]
        [[ "${lines[0]}" == "busybox" ]]
        
        # inspect --format='{{.Node.IP}}', return one line: Node ip
        run docker_swarm inspect --format='{{.Node.IP}}' test_container
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 1 ]
        [[ "${lines[0]}" == "127.0.0.1" ]]
}
