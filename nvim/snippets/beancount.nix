{ pkgs, ... }:
{
  snippets.filetype.beancount = {
    build.lsp = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Lencerf/vscode-beancount/refs/tags/v0.13.0/snippets/beancount.json";
      hash = "sha256-2WZVGLERfPoQikFSbBfQdzli9rhGsh6HutP/K1HY/BI=";
    };
  };
}
