#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker load should return success, every node should load the image" {
        start_docker 1
        swarm_manage
        run docker_swarm pull busybox sleep 60
        [ "$status" -eq 0 ]
        run docker -H  ${HOSTS[0]} images
        [ "${#lines[@]}" -eq  2 ]
}
