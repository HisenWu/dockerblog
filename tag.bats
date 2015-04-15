
#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm tag image should return success" {
        start_docker 1
        swarm_manage
        
        run docker_swarm pull busybox:latest sleep 60
        [ "$status" -eq 0 ]

        #tag image
        run docker_swarm tag busybox tag_busybox:test
        [ "$status" -eq 0 ]
        
        #docker_swarm verify
        run docker_swarm images
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"tag_busybox"* ]]

        #docker node verify
        run docker -H ${HOST[0]} images
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"tag_busybox"* ]]
}
