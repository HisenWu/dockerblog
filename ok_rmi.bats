#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "swarm delete image should return success" {
        start_docker 1
        swarm_manage
        run docker_swarm pull busybox
        [ "$status" -eq 0 ]
        
        run docker_swarm rmi busybox
        [ "$status" -eq 0 ]
        
        run docker_swarm images
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 1 ]
        
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
                [ "${#lines[@]}" -eq 1 ]
        done
}
