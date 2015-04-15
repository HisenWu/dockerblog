
#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker commit container should return success" {
        start_docker 1
        start_manage
        run docker_swarm run -d --name delete_container busybox
        [ "$status" -eq 0 ]
        [[ "${#lines[1]}" ==  *"delete_container"* ]]
        run docker_swarm rm delete_container
        [ "$status" -eq 0 ]
}
