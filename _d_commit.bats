#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker commit" {
        start_docker 3
        swarm_manage
        
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]
        
        # make sure container exists
	run docker_swarm ps -l
        [ "${#lines[@]}" -eq 2 ]
        [[ "${lines[1]}" ==  *"test_container"* ]]
        
        # no comming image before commit 
        run docker_swarm images -q
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" != *"commit_image_busybox"* ]]
        
        # commit container
        run docker_swarm commit test_container commit_image_busybox
        [ "$status" -eq 0 ]

        # verify after commit 
        run docker_swarm images -q
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"commit_image_busybox"* ]]
}
