#!/usr/bin/env bats

load helpers

function teardown(){
        swarm_manage_cleanup
        stop_docker
}

@test "docker search" {
        TEMP_FILE=$(mktemp)
        start_docker 3
        swarm_manage

        # search image (not exist)
        run docker_swarm search $TEMP_FILE
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 1 ]
        [[ "${lines[0]}" == *"DESCRIPTION"* ]]
        
        # search busybox (image exist)
        run docker_swarm search busybox
        [ "$status" -eq 0 ]
        # search existed image, output: latest + header at least
        [ "${#lines[@]}" -ge 2 ]
        # Every line should contain "busybox" exclude the first head line 
	for((i=1; i<${#lines[@]}; i++)); do
		[[ "${lines[i]}" == *"busybox"* ]]
	done
}
