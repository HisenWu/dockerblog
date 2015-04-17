
#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm image" {
        start_docker 3
        swarm_manage
        
        run docker_swarm pull busybox
        [ "$status" -eq 0 ]

        # images
        run docker_swarm images
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"busybox"* ]]
}
