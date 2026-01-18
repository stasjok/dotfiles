{
  snippets.vscode = {
    language = "gitcommit";
    snippets = {
      build = {
        prefix = "build";
        description = "Changes that affect the build system or external dependencies";
        body = ''
          build(''${1:scope}): ''${2:commit}

        '';
      };
      chore = {
        prefix = "chore";
        description = "Changes which doesn't change source code or tests e.g. changes to the build process, auxiliary tools, libraries";
        body = ''
          chore(''${1:scope}): ''${2:commit}

        '';
      };
      ci = {
        prefix = "ci";
        description = "Changes to CI configuration files and scripts";
        body = ''
          ci(''${1:scope}): ''${2:commit}

        '';
      };
      docs = {
        prefix = "docs";
        description = "Documentation only changes";
        body = ''
          docs(''${1:scope}): ''${2:commit}

        '';
      };
      feat = {
        prefix = "feat";
        description = "A new feature";
        body = ''
          feat(''${1:scope}): ''${2:commit}

        '';
      };
      fix = {
        prefix = "fix";
        description = "A bug fix";
        body = ''
          fix(''${1:scope}): ''${2:commit}

        '';
      };
      perf = {
        prefix = "perf";
        description = "A code change that improves performance";
        body = ''
          perf(''${1:scope}): ''${2:commit}

        '';
      };
      refactor = {
        prefix = "refactor";
        description = "A code change that neither fixes a bug nor adds a feature";
        body = "refactor(\${1:scope}): \${2:commit}\n\n";
      };
      revert = {
        prefix = "revert";
        description = "Revert something";
        body = ''
          revert(''${1:scope}): ''${2:commit}

        '';
      };
      style = {
        prefix = "style";
        description = "Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)";
        body = ''
          style(''${1:scope}): ''${2:commit}

        '';
      };
      test = {
        prefix = "test";
        description = "Adding missing tests or correcting existing tests";
        body = ''
          test(''${1:scope}): ''${2:commit}

        '';
      };
    };
  };
}
