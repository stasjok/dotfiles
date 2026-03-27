{
  snippets.filetype.salt = {
    lsp = {
      backup = {
        prefix = "backup";
        description = "Backing up files that are replaced by the file.managed and file.recurse states";
        body = "backup: minion";
      };
      check_cmd = {
        prefix = "check_cmd";
        description = "Determine that a state did or did not run as expected";
        body = ''
          check_cmd:
          		- ''${1:cmd}'';
      };
      exclude = {
        prefix = "exclude";
        description = "The exclude statement";
        body = ''
          exclude:
          	- ''${1:sls}: ''${2:name}'';
      };
      extend = {
        prefix = "extend";
        description = "The extend statement";
        body = ''
          extend:
          	''${1:id_to_extend}:
          		''${2:module_name}:
          			- ''${3:key}: '';
      };
      "file.managed" = {
        prefix = "file.managed";
        description = "Manage a given file";
        body = ''
          file.managed:
          	- name: ''${1:/path/to/file}
          	- source: ''${2:salt://''${3:name}/files/''${4:config}}
          	- user: ''${5:root}
          	- group: ''${6:root}
          	- mode: ''${7:644}
          	- makedirs: ''${8:true}
          	- template: ''${9:jinja}
          	- context:
          			$3: {{ $3 | yaml }}'';
      };
      "file.replace" = {
        prefix = "file.replace";
        description = "Maintain an edit in a file";
        body = ''
          file.replace:
          	- name: ''${1:/path/to/file}
          	- pattern: ''${2:match_regexp}
          	- repl: ''${3:replacement_text}'';
      };
      "file.serialize" = {
        prefix = "file.serialize";
        description = "Serializes dataset and store it into managed file";
        body = ''
          file.serialize:
          	- name: ''${1:file_path}
          	- dataset: ''${2:{{ ''${3:data} | yaml }}}
          	- formatter: ''${4:configparser}
          	- user: ''${5:root}
          	- group: ''${6:root}
          	- mode: ''${7:644}
          	- makedirs: ''${8:true}'';
      };
      files_switch = {
        prefix = "files_switch";
        description = "source: files_switch";
        body = "{{ files_switch([\"\${1:\${2:name}.conf}\"], lookup=\"\${2:name}-config-file-managed\") }}";
      };
      fire_event = {
        prefix = "fire_event";
        description = "Send an event to the Salt Master upon completion of that individual state";
        body = "fire_event: \${1:True}";
      };
      import_files_switch = {
        prefix = "import_files_switch";
        description = "Import files_switch";
        body = "{%- from tplroot | path_join(\"libtofs.jinja\") import files_switch %}";
      };
      import_map = {
        prefix = "import_map";
        description = "Import from map.jinja";
        body = "{%- from tplroot | path_join(\"map.jinja\") import mapdata as \${1:name} %}";
      };
      onchanges = {
        prefix = "onchanges";
        description = "Makes a state only apply if the required states generate changes";
        body = "onchanges:\n\t\t- \${1:\${2:file}: \${3:state_id}}";
      };
      onchanges_any = {
        prefix = "onchanges_any";
        description = "Makes a state only apply if one of the required states generates changes";
        body = ''
          onchanges_any:
          		- ''${1:''${2:file}: ''${3:state_id}}
          		- ''${4:''${5:file}: ''${6:state_id}}'';
      };
      onchanges_in = {
        prefix = "onchanges_in";
        description = "Makes a state only apply if the required states generate changes";
        body = ''
          onchanges_in:
          		- ''${1:''${2:service}: ''${3:state_id}}'';
      };
      onfail = {
        prefix = "onfail";
        description = "Make a state only apply as a response to the failure of another state";
        body = ''
          onfail:
          		- ''${1:''${2:service}: ''${3:state_id}}'';
      };
      onfail_any = {
        prefix = "onfail_any";
        description = "Make a state only apply as a response to the failure of at least one other state";
        body = ''
          onfail_any:
          		- ''${1:''${2:service}: ''${3:state_id}}'';
      };
      onfail_in = {
        prefix = "onfail_in";
        description = "Make a state only apply as a response to the failure of another state";
        body = ''
          onfail_in:
          		- ''${1:''${2:service}: ''${3:state_id}}'';
      };
      onlyif = {
        prefix = "onlyif";
        description = "If each command listed in onlyif returns True, then the state is run";
        body = ''
          onlyif:
          		- ''${1:fun: ''${2:file.file_exists}}'';
      };
      "pkg.installed" = {
        prefix = "pkg.installed";
        description = "Ensure that the package is installed";
        body = ''
          pkg.installed:
          	- name: ''${1:package_name}'';
      };
      "pkg.installed.pkgs" = {
        prefix = "pkg.installed.pkgs";
        description = "Ensure that multiple packages are installed";
        body = ''
          pkg.installed:
          	- pkgs:$1'';
      };
      "pkg.purged" = {
        prefix = "pkg.purged";
        description = "Verify that a package is purged";
        body = ''
          pkg.purged:
          	- name: ''${1:package_name}'';
      };
      "pkg.purged.pkg" = {
        prefix = "pkg.purged.pkg";
        description = "Verify that list of packages is purged";
        body = ''
          pkg.purged:
          	- pkgs:$1'';
      };
      "pkg.removed" = {
        prefix = "pkg.removed";
        description = "Verify that a package is not installed";
        body = ''
          pkg.removed:
          	- name: ''${1:package_name}'';
      };
      "pkg.removed.pkg" = {
        prefix = "pkg.removed.pkg";
        description = "Verify that list of packages is removed";
        body = ''
          pkg.removed:
          	- pkgs:$1'';
      };
      prereq = {
        prefix = "prereq";
        description = "Actions to be taken based on the expected results of a state that has not yet been executed";
        body = ''
          prereq:
          		- ''${1:''${2:file}: ''${3:state_id}}'';
      };
      prereq_in = {
        prefix = "prereq_in";
        description = "Actions to be taken based on the expected results of a state that has not yet been executed";
        body = ''
          prereq_in:
          		- ''${1:''${2:file}: ''${3:state_id}}'';
      };
      reload_grains = {
        prefix = "reload_grains";
        description = "Reload Grains";
        body = "reload_grains: True";
      };
      reload_modules = {
        prefix = "reload_modules";
        description = "Reload modules";
        body = "reload_modules: True";
      };
      reload_pillar = {
        prefix = "reload_pillar";
        description = "Reload Pillar";
        body = "reload_pillar: True";
      };
      require = {
        prefix = "require";
        description = "Demands that the required state executes before";
        body = ''
          require:
          		- ''${1:''${2:file}: ''${3:state_id}}'';
      };
      require_any = {
        prefix = "require_any";
        description = "Demands that one of the required states executes before the dependent state";
        body = ''
          require_any:
          		- ''${1:''${2:file}: ''${3:state_id}}
          		- ''${4:''${5:file}: ''${6:state_id}}'';
      };
      require_in = {
        prefix = "require_in";
        description = "Demands that the required state executes before";
        body = ''
          require_in:
          		- ''${1:''${2:file}: ''${3:state_id}}'';
      };
      retry = {
        prefix = "retry";
        description = "Execute a state multiple times until a desired result is obtained";
        body = ''
          retry:
          		attempts: ''${1:5}
          		interval: ''${2:30}
          		splay: ''${3:10}'';
      };
      runas = {
        prefix = "runas";
        description = "Set the user which will be used to run the command";
        body = "runas: \${1:user}";
      };
      "service.running" = {
        prefix = "service.running";
        description = "Ensure that the service is running";
        body = ''
          service.running:
          	- name: ''${1:service_name}
          	- enable: ''${2:true}
          	- reload: ''${3:true}'';
      };
      "test.nop" = {
        prefix = "test.nop";
        description = "A no-op state that does nothing";
        body = "test.nop: []";
      };
      tplroot = {
        prefix = "tplroot";
        description = "Get the tplroot from tpldir";
        body = ''{%- set tplroot = tpldir.split("/")[0] %}'';
      };
      id_prefix = {
        prefix = "id_prefix";
        description = "A default prefix for state IDs";
        body = ''{%- set id_prefix = sls | replace(".", " - ") %}'';
      };
      unless = {
        prefix = "unless";
        description = "State should only run when any of the specified commands return False";
        body = ''
          unless:
          		- ''${1:fun: ''${2:file.file_exists}}'';
      };
      use = {
        prefix = "use";
        description = "Inherit the arguments passed in another id declaration";
        body = ''
          use:
          		- ''${1:''${2:file}: ''${3:state_id}}'';
      };
      use_in = {
        prefix = "use_in";
        description = "Inherit the arguments passed in another id declaration";
        body = ''
          use_in:
          		- ''${1:''${2:file}: ''${3:state_id}}'';
      };
      watch = {
        prefix = "watch";
        description = "Add additional behavior when there are changes";
        body = ''
          watch:
          		- ''${1:''${2:file}: ''${3:state_id}}'';
      };
      watch_any = {
        prefix = "watch_any";
        description = "Add additional behavior when there are changes in any states";
        body = ''
          watch_any:
          		- ''${1:''${2:file}: ''${3:state_id}}
          		- ''${4:''${5:file}: ''${6:state_id}}'';
      };
      watch_in = {
        prefix = "watch_in";
        description = "Add additional behavior when there are changes";
        body = ''
          watch_in:
          		- ''${1:''${2:service}: ''${3:state_id}}'';
      };
    };
  };
}
