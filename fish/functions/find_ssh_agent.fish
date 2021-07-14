function find_ssh_agent -d "find or run ssh-agent"
    if set -q SSH_AGENT_PID; and set -q SSH_AUTH_SOCK
        # if variables already defined, then try to connect to agent
        ssh-add -l &>/dev/null
        test $status -ne 2; and return
    end
    set -l user_id (id -u)
    set -l ssh_tmp_dirs /tmp/ssh-*
    set -l ssh_agent_pid (pgrep --exact --newest --uid $user_id ssh-agent)
    if test $status -eq 0; and string length -q -- $ssh_tmp_dirs
        set -l ssh_auth_sock (find $ssh_tmp_dirs -type s -name 'agent.*' -user $user_id -exec ls -1 -t {} +)
        set -l ssh_agent_sock $ssh_auth_sock[1]
        set --global --export SSH_AGENT_PID $ssh_agent_pid
        set --global --export SSH_AUTH_SOCK $ssh_agent_sock
    else
        string length -q -- $ssh_tmp_dirs; and find $ssh_tmp_dirs -user $user_id -delete &> /dev/null
        eval (ssh-agent -c)
    end
end
