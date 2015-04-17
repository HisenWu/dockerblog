#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker load should return success, every node should load the image" {
        start_docker 3
        swarm_manage
        run docker_swarm pull busybox
        [ "$status" -eq 0 ]

        # docker_swarm verify
        run docker_swarm images
        [ "$status" -eq 0 ]
        [[ "${lines[*]}" == *"busybox"* ]]

        # node verify
        for host in ${HOSTS[@]}; do
                run docker -H $host images
                [ "$status" -eq 0 ]
                [[ "${lines[*]}" == *"busybox"* ]]
        done
}