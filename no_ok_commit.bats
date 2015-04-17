#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker commit" {
        start_docker 1
        swarm_manage
        
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]

        ##commit container
        run docker_swarm commit test_container commit_image_busybox
        [ "$status" -eq 0 ]

        #cluster refresh the state of image need 30 seconds
        sleep 35
        
        ##verify after commit 
        run docker_swarm images
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"commit_image_busybox"* ]]
}
