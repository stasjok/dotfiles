{
  # Source: https://github.com/qvalentin/helm-ls.nvim/blob/main/ftdetect/filetype.lua
  filetype.pattern = {
    ".*/templates/.*%.tpl" = "helm";
    ".*/templates/.*%.ya?ml" = "helm";
    ".*/templates/.*%.txt" = "helm";
    "helmfile.*%.ya?ml" = "helm";
    "helmfile.*%.ya?ml.gotmpl" = "helm";
    "values.*%.yaml" = "yaml.helm-values";
  };
}
