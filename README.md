Network Ping Checktools
==========================================

method
------------------------------------------
User gives a list of hosts to ping / tcpping.
If return non-zero, call another command to record the issue.

usage
------------------------------------------

### ping the hosts
```
./netping.sh ping-hosts.txt "ping -D -c 1 {1}" "echo '========== sleep 10 ====='; sleep 10; echo '==========================='"
```

In this case,
`ping-hosts.txt` is the hosts you would like to ping and check.
`"ping -D -c 1 {1}"` is the command and arguments you would like to call.
`"echo '========== sleep 10 ====='; sleep 10; echo '==========================='"`
is the command to call when the previous command with non-zero exits.


