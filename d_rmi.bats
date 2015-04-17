#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker rmi" {
        start_docker 3
        swarm_manage
        run docker_swarm pull busybox
        [ "$status" -eq 0 ]
        
        # this test presupposition: do not run image
        run docker_swarm rmi busybox
        [ "$status" -eq 0 ]
        # cluster refresh the state of image need 30 seconds
        sleep 35
        
        # swarm verify
        run docker_swarm images
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 1 ]
        # node verify
        for host in ${HOSTS[@]}; do
                run docker -H $host images
                [ "$status" -eq 0 ]
                [ "${#lines[@]}" -eq 1 ]
        done
}
