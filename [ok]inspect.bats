#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker inspect the running container" {
        start_docker 1
        swarm_manage
        #running container
        run docker_swarm run -d --name test_container busybox sleep 500
        [ "$status" -eq 0 ]
        
        #inspect
        run docker_swarm inspect test_container
        [ "$status" -eq 0 ]
        [[ "${lines[1]}" == *"AppArmorProfile"* ]]
        #--format
        run docker_swarm inspect --format='{{.Config.Image}}' test_container
        [ "$status" -eq 0 ]
        [[ "${lines[0]}" == "busybox" ]]
}
