;; inherits: yaml

; Source: https://github.com/pearofducks/ansible-vim/blob/6c42a448e30bc48ae98792bce38970148b0e3c9d/lua/ansible/init.lua#L22-L85

; Ansible: task structure and control flow
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @keyword.ansible.control
      (#any-of? @keyword.ansible.control
        "name" "hosts"
        "tasks" "handlers" "pre_tasks" "post_tasks"
        "block" "rescue" "always"
        "when" "changed_when" "failed_when"
        "notify" "listen"
        "register"
        "action" "local_action"
        "include" "include_role" "include_tasks" "include_vars"
        "import_role" "import_playbook" "import_tasks"
        "roles" "collections")))
  (#set! priority 105))

; Ansible: loop keywords
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @keyword.ansible.loop
      (#any-of? @keyword.ansible.loop
        "loop" "loop_control" "until" "retries" "delay")))
  (#set! priority 105))

; Ansible: with_* loop keywords (with_items, with_dict, with_fileglob, etc.)
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @keyword.ansible.loop
      (#lua-match? @keyword.ansible.loop "^with_")))
  (#set! priority 105))

; Ansible: privilege escalation, execution control, and directives
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @keyword.ansible.directive
      (#any-of? @keyword.ansible.directive
        "become" "become_exe" "become_flags" "become_method" "become_user" "become_pass"
        "check_mode" "diff" "no_log"
        "any_errors_fatal" "ignore_errors" "ignore_unreachable" "max_fail_percentage"
        "environment" "vars" "vars_files" "vars_prompt"
        "connection" "port" "remote_user"
        "async" "poll" "throttle" "timeout"
        "order" "run_once" "serial" "strategy"
        "delegate_facts" "delegate_to"
        "tags" "args" "force_handlers"
        "debugger" "always_run" "prompt_l10n"
        "gather_facts" "gather_subset" "gather_timeout" "fact_path"
        "module_defaults")))
  (#set! priority 105))

; Ansible: debug module
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @keyword.ansible.debug
      (#eq? @keyword.ansible.debug "debug")))
  (#set! priority 105))
