{
  filetype = {
    pattern = {
      # Ansible
      ".*ansible[^/]*/.*%.ya?ml" = "yaml.ansible";
      ".*/infrastructure/.*%.ya?ml" = "yaml.ansible";

      # Ansible hosts
      ".*ansible[^/]*/.*production" = "ansible_hosts";
      ".*ansible[^/]*/.*qa" = "ansible_hosts";
      ".*ansible[^/]*/.*testing" = "ansible_hosts";
    };

    # Avoid matching Taskfile
    filename = {
      "Taskfile.yaml" = "yaml";
      "Taskfile.yml" = "yaml";
    };
  };

  # Indent
  extraFiles."after/indent/ansible.vim".text = builtins.readFile ./indent.vim;
}
