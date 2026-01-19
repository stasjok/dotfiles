{ lib, ... }:
{
  snippets.vscode = lib.singleton {
    language = "snippets";
    snippets = {
      "snippet" = {
        prefix = "snippet";
        description = "Define a snippet";
        body = [
          "snippet \${1:trigger_and_description}"
          "\t$0"
        ];
      };
      "$" = {
        prefix = "$";
        description = "A tab stop with placeholder";
        body = "\${\${1:1}:\${2:default_text}}";
      };
      "\${VISUAL}" = {
        prefix = "{VISUAL}";
        description = "The VISUAL stop";
        body = "\\\${VISUAL\\}";
      };
      "\${TM_SELECTED_TEXT}" = {
        prefix = "{TM_SELECTED_TEXT}";
        description = "The currently selected text or the empty string";
        body = "\\\${TM_SELECTED_TEXT}";
      };
    };
  };
}
