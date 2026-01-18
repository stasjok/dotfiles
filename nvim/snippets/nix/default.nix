{
  snippets = {
    vscode = {
      language = "nix";
      snippets = {
        "if" = {
          prefix = "if";
          description = "Conditional";
          body = "if $1 then $2 else $0";

        };
        "assert" = {
          prefix = "assert";
          description = "Assertion";
          body = "assert $1; $0";
        };
        "with" = {
          prefix = "with";
          description = "A with-expression";
          body = "with $1; $0";
        };
      };
    };

    lua.nix.text = builtins.readFile ./nix.lua;
  };
}
