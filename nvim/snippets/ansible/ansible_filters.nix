{ lib, ... }:
{
  snippets.vscode = lib.singleton {
    language = "ansible_filters";
    snippets = {
      combine = {
        prefix = "combine";
        description = "Merge hashes";
        body = "combine(\${1:hash}\${2:, recursive=True})";
      };
      dict2items = {
        prefix = "dict2items";
        description = "Turn a dictionary into a list of items";
        body = "dict2items(key_name='\${1:name}', value_name='\${2:value}')";
      };
      flatten = {
        prefix = "flatten";
        description = "Flatten a list";
        body = "flatten(levels=\${1:1})";
      };
      items2dict = {
        prefix = "items2dict";
        description = "Turn a list of dicts with 2 keys, into a dict";
        body = "items2dict(key_name='\${1:name}', value_name='\${2:value}')";
      };
      mandatory = {
        prefix = "mandatory";
        description = "Return error if some value is undefined";
        body = "mandatory(\${1:msg='\${2:Mandatory variable is not defined.}'})";
      };
      match = {
        prefix = "match";
        description = "Match strings against a substring or a regular expression";
        body = "match(\${1:'\${2:regex}'}\${3:\${4:, multiline=True}\${5:, ignorecase=True}})";
      };
      regex_findall = {
        prefix = "regex_findall";
        description = "Search for all occurrences of regex matches";
        body = "regex_findall(\${1:'\${2:regex}'}\${3:\${4:, multiline=True}\${5:, ignorecase=True}})";
      };
      search = {
        prefix = "search";
        description = "Match strings against a substring or a regular expression";
        body = "search(\${1:'\${2:regex}'}\${3:\${4:, multiline=True}\${5:, ignorecase=True}})";
      };
      ternary = {
        prefix = "ternary";
        description = "Value to use when the test returns true and another when the test returns false";
        body = "ternary(\${1:'val_if_true'}, \${2:'val_if_false'}\${3/.+/, /}\${3:'val_if_none'})";
      };
    };
  };

}
