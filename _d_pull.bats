#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker pull" {
        start_docker 3
        swarm_manage

        # make sure no image exists
        run docker_swarm images -q
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 0 ]

        for host in ${HOSTS[@]}; do
                run docker -H $host images -q
                [ "$status" -eq 0 ]
                [ "${#lines[@]}" -eq 0 ]
        done

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
