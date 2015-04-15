#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker export: export the contents of contanier's filesystem as a tar archive to STDOUT" {
        start_docker 1
        swarm_manage
        #run a container to export
        run docker_swarm run -d --name export_container busybox sleep 60
        [ "$status" -eq 0 ]
        run docker_swarm export export_container > container_busybox.tar sleep 10
        [ "$status" -eq 0 ]
}
