#!/usr/bin/env fish

function do_test
    set -f test_name $argv[1]
    set -f test_command $argv[2..]
    set -f output ($test_command &| string collect)
    set -f exit_code $pipestatus[1]
    if test $exit_code -eq 0
        set -f color green
        set -f result Success
    else
        set -f color red
        set -f result Fail
        set test_name $test_name\n\n(printf "%8sCommand: %s" "" (string join " " -- $test_command))
        set test_name $test_name\n(printf "%8sExit code: %s" "" $exit_code)
        set test_name $test_name\n(printf "%8sOutput:\n%s" "" $output | string collect)\n
        set number_of_fails (math $number_of_fails + 1)
    end
    printf "%s%-7s%s | %s\n" (set_color $color) $result (set_color normal) $test_name
end

set number_of_fails 0

# Ansible
set -l ansible_version (ansible --version | head -n 1 | grep -o "[0-9.]\+")
set -l ansible_lint_ansible_version (ansible-lint --nocolor --version | grep -oP "ansible\s+\K[\d.]+")
do_test "Ansible version should match version from ansible-lint" \
    test $ansible_version = $ansible_lint_ansible_version
do_test "Ansible collections are in python path (for ansible-language-server)" \
    python3 -c "import ansible_collections"

exit $number_of_fails
