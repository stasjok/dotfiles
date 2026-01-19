{
  snippets.filetype.sh = {
    lsp = {
      "#!" = {
        prefix = "#!";
        description = "Shebang";
        body = ''
          #!/usr/bin/env ''${1:bash}
        '';
      };
      "$" = {
        prefix = "$";
        description = "Variable";
        body = "\\$\\{\${1:\${2:var}[\${3:@}]}\\}";
      };
      BASH_SOURCE = {
        prefix = "BASH_SOURCE";
        description = "BASH_SOURCE variable";
        body = "\${BASH_SOURCE[\${1:0}]}";
      };
      case = {
        prefix = "case";
        description = "Case statement";
        body = ''
          case ''${1:\''$''${2:var}} in
          	''${3:pattern})
          		$4
          		;;
          esac'';
      };
      elif = {
        prefix = "elif";
        description = "Elif condition";
        body = ''
          elif ''${1:[[ ''${2:condition} ]]}; then
          	$3'';
      };
      "else" = {
        prefix = "else";
        description = "Else statement";
        body = ''
          else
          	$0'';
      };
      for = {
        prefix = "for";
        description = "For loop";
        body = ''
          for ''${1:i} in ''${2:words}; do
          	$3
          done'';
      };
      fori = {
        prefix = "fori";
        description = "Three-expression for loop";
        body = ''
          for (( ''${1:i}=''${2:0}; $1 ''${3:< ''${4:10}}; $1''${5:++} )); do
          	$6
          done'';
      };
      forif = {
        prefix = "forif";
        description = "Full three-expression for loop";
        body = ''
          for (( ''${1:''${2:i}=''${3:0}}; ''${4:$2 ''${5:< ''${6:count}}}; ''${7:$2''${8:++}} )); do
          	$9
          done'';
      };
      function = {
        prefix = "function";
        description = "Function";
        body = ''
          function ''${1:function_name} {
          	$2
          }'';
      };
      getopt = {
        prefix = "getopt";
        description = "Args parsing with getopt";
        body = ''
          opts=$(getopt --name "''${1:$(basename -- "''$\{BASH_SOURCE[0]\}")}" \
          	--options ''${2:h''${3}} \
          	--longoptions ''${4:help''${5}} \
          	-- "$@")
          eval "set -- $opts"

          function usage {
          	cat <<USAGE
          ''${6:Description}

          Usage:
          	''${1} [options]

          Options:
          	-h, --help  Display this help and exit.
          USAGE
          }

          while true; do
          	case \$1 in
          		''${7:-h|--help)
          			usage
          			exit 0
          			;;
          		}''${8:-''${9:o}|--''${10:opt}})
          			''${11:''${12:''${10}}=''${13:\$2}}
          			shift''${14/.+/ /}''${14:2}
          			;;
          		--)
          			shift
          			break
          			;;
          	esac
          done'';
      };
      here = {
        prefix = "here";
        description = "Here Document";
        body = ''
          <<-''${1:EOF}
          	$0
          ''${1/["'](.*)["']/$1/}'';
      };
      "if" = {
        prefix = "if";
        description = "If statement";
        body = ''
          if ''${1:[[ ''${2:condition} ]]}; then
          	$3
          fi'';
      };
      root_needed = {
        prefix = "root_needed";
        description = "Script must be run as root";
        body = ''
          if (( EUID != 0 )); then
          	echo "''${1:This script must be run as root}" >&2
          	exit ''${2:99}
          fi'';
      };
      strict = {
        prefix = "strict";
        description = "Bash Strict Mode";
        body = ''
          set -o errexit -o errtrace -o pipefail -o nounset
          (shopt -p inherit_errexit &>/dev/null) && shopt -s inherit_errexit

          function failure() {
          	local lineno=\$1
          	local exitcode=\$2
          	local command=\$3
          	echo "Failed with exit code $exitcode at line $lineno: $command" >&2
          }

          trap 'failure \''${LINENO} \$? "\''${BASH_COMMAND}"' ERR

          IFS=$'\n\t'
        '';
      };
      sw = {
        prefix = "sw";
        description = "Case pattern";
        body = ''
          ''${1:*})
          	$2
          	;;'';
      };
      swopt = {
        prefix = "swopt";
        description = "Case opt for getopt";
        body = ''
          ''${1:-''${2:o}|--''${3:opt}})
          	''${4:''${5:''${3}}=''${6:\$2}}
          	shift''${7/.+/ /}''${7:2}
          	;;'';
      };
      until = {
        prefix = "until";
        description = "Until loop";
        body = ''
          until ''${1:[[ ''${2:condition} ]]}; do
          	$3
          done'';
      };
      while = {
        prefix = "while";
        description = "While loop";
        body = ''
          while ''${1:[[ ''${2:condition} ]]}; do
          	$3
          done'';
      };
    };
  };
}
