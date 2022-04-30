function (status basename | string split -r -m 1 -f 1 .) -d "Run salt commands via SSH"
    set -l command (status function)
    test -z $salt_hostname; and read -U -P "Enter Salt hostname: " salt_hostname
    ssh -t root@$salt_hostname $command --force-color (string escape -- $argv)
end
