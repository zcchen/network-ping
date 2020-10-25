#!/bin/bash

#date ; cat hosts.txt | parallel --timeout 1 -j4 ping -D -c 1 {} ; date

usage="$0 <hosts-file> <ping-command> <action-when-failed> \n
    <host-file>,    the host-file will be use to ping / tcpping. \n
    <ping-command>, the ping / tcpping command with arguments,
        use '{}' to replace the args from <host-file>.  \n
    <action-when-failed>,   the command to be called when error happenes \n
\n
note: please use \"\" to quote the command setup
"

PARALLEL_PARAM=(--timeout 10 --colsep ' ' -j4)

if [[ $# -ne 3 ]]; then
    echo -e $usage
    exit 1
fi
program_name=$0

action4failed_pid=0
function is_action4failed_running()
{
    if [[ $action4failed_pid -eq 0 ]]; then
        # not started
        #echo "action4failed did not started ..."
        return 0
    else
        if [[ -z $(ps -ef | awk '{print $2}' | grep $action4failed_pid) ]]; then
            # started but finished
            action4failed_pid=0
            #echo "action4failed is stopped..."
            return 0
        else    # started and ongoing
            #echo "action4failed is running..."
            return 1
        fi
    fi
}

function trap_kill()
{
    pids="$@"
    for p in $pids; do
        kill $p
    done
}

function main()
{
    local hostfile=$1
    local pingcommand=$2
    local action4failed=$3

    while [ 1 ]; do
        echo "--------------- $(date +'%Y-%m-%d %H:%M:%S.%N') --------------"
        if [[ $action4failed_pid -ne 0 ]]; then
            trap "trap_kill $action4failed_pid $(pgrep -f $program_name)" SIGTERM SIGQUIT SIGINT SIGKILL
        else
            trap "trap_kill $(pgrep -f $program_name)" SIGTERM SIGQUIT SIGINT SIGKILL
        fi
        cat $hostfile | parallel ${PARALLEL_PARAM[*]} $pingcommand
        if [[ $? -ne 0 ]]; then
            is_action4failed_running
            if [[ $? -eq 0 && -n $action4failed ]]; then
                bash -c "$action4failed" &
                action4failed_pid=$!
                trap "trap_kill $action4failed_pid $(pgrep -f $program_name)" SIGTERM SIGQUIT SIGINT SIGKILL
            fi
        fi
        sleep 1
        echo "------------------------------------------------------------"
    done
}

main "$@"
