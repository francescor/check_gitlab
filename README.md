# check_gitlab
Basic nagios check for gitlab Health Check http://git.bwlocal.it/help/user/admin_area/monitoring/health_check.md

Basic usage:
```
check_gitlab.rb  --host mygitlab.xxx.com  --uri '/-/liveness' -w 0 -c 1
```

## Example

```
$ ruby check_gitlab.rb  --host mygitlab.xxx.com --port 7575  --uri '/-/liveness' -w 0 -c 1
OK: Full json: {"db_check"=>{"status"=>"ok"}, "redis_check"=>{"status"=>"ok"}, "cache_check"=>{"status"=>"ok"}, "queues_check"=>{"status"=>"ok"}, "shared_state_check"=>{"status"=>"ok"}, "gitaly_check"=>{"status"=>"ok"}}|number_of_fails=0.0;;;;
```

## Help

```
ruby check_gitlab.rb  --help
Usage: check_gitlab [options]
    -H, --host HOST
    -P, --port PORT
    -U, --uri URI
    -w RANGE
    -c RANGE
    -t TIMEOUT
```

## host definition

```
define service {
        use                             generic-service
        host_name                       mygitlab.xxx.com
        service_description             check_gitlab_health
        check_command                   check_gitlab_health!0!1!80
        check_interval                  10
}

define service {
        use                             generic-service
        host_name                       mygitlab.xxx.com
        service_description             check_gitlab_readiness
        check_command                   check_gitlab_readiness!0!1!80
        check_interval                  10
}
define service {
        use                             generic-service
        host_name                       mygitlab.xxx.com
        service_description             check_gitlab_liveness
        check_command                   check_gitlab_liveness!0!1!80
        check_interval                  10
}
```

## command definition

```
# adapt $USER3$ in the code below, or just paste the path to your executable check_gitlab.rb
define command{
        command_name    check_gitlab_health
        command_line    $USER3$/check_gitlab/check_gitlab.rb --host '$HOSTNAME$' -w '$ARG1$' -c '$ARG2$' --port '$ARG3$' --uri '/-/health'

}

define command{
        command_name    check_gitlab_readiness
        command_line    $USER3$/check_gitlab/check_gitlab.rb --host '$HOSTNAME$' -w '$ARG1$' -c '$ARG2$' --port '$ARG3$' --uri '/-/readiness'
}

define command{
        command_name    check_gitlab_liveness
        command_line    $USER3$/check_gitlab/check_gitlab.rb --host '$HOSTNAME$' -w '$ARG1$' -c '$ARG2$' --port '$ARG3$' --uri '/-/liveness'
}
```

## Requirements

Gitlab 12.5.3

https://github.com/dbroeglin/nagios_check 
```
gem install nagios-check 
```
