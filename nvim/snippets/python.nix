{
  snippets.filetype.python = {
    lsp = {
      "#!" = {
        prefix = "#!";
        description = "Shebang";
        body = "#!/usr/bin/env python\${1:3}\n";
      };
      class = {
        prefix = "class";
        description = "Class definition";
        body = "class \${1:ClassName}\${2:(\${3:object})}:\n\t'''\${4:docstring for $1}'''\n\t$5";
      };
      classi = {
        prefix = "classi";
        description = "Class definition with __init__";
        body = "class \${1:ClassName}\${2:(\${3:object})}:\n\t'''\${4:docstring for $1}'''\n\n\tdef __init__(self\${5:, \${6:args}})\${7: -> None}:\n\t\t$8";
      };
      dcp = {
        prefix = "dcp";
        description = "Dict comprehension";
        body = "{\${5:key_exprn}: \${6:value_expr} for \${1:item} in \${2:items}\${3: if \${4:condition}}}";
      };
      def = {
        prefix = "def";
        description = "Function definition";
        body = "def \${1:function}(\${2:args})\${3: -> \${4:None}}:\n\t'''\${5:docstring for $1}'''\n\t$6";
      };
      defi = {
        prefix = "defi";
        description = "Class __init__ definition";
        body = "def __init__(self\${1:, \${2:args}})\${3: -> None}:\n\t$4";
      };
      dowhile = {
        prefix = "dowhile";
        description = "Same as do...while in other languages";
        body = "while True:\n\t$2\n\tif \${1:condition}:\n\t\tbreak";
      };
      elif = {
        prefix = "elif";
        description = "Elif";
        body = "elif \${1:condition}:\n\t$2";
      };
      "else" = {
        prefix = "else";
        description = "Else statement";
        body = "else:\n\t1";
      };
      except = {
        prefix = "except";
        description = "Except statement";
        body = "except \${1:Exception} as \${2:e}:\n\t\${3:raise $2}";
      };
      finally = {
        prefix = "finally";
        description = "Finally statement";
        body = "finally:\n\t\${1:pass}";
      };
      for = {
        prefix = "for";
        description = "For loop statement";
        body = "for \${1:item} in \${2:items}:\n\t$3";
      };
      from = {
        prefix = "from";
        description = "From package import";
        body = "from \${1:package} import \${0:module}";
      };
      "if" = {
        prefix = "if";
        description = "If";
        body = "if \${1:condition}:\n\t$2";
      };
      ife = {
        prefix = "ife";
        description = "If / Else";
        body = "if \${1:condition}:\n\t$2\nelse:\n\t\${3:pass}";
      };
      ifee = {
        prefix = "ifee";
        description = "If / Elif / Else";
        body = "if \${1:condition}:\n\t$2\nelif \${3:condition}:\n\t\${4:pass}\nelse:\n\t\${5:pass}";
      };
      ifm = {
        prefix = "ifm";
        description = "If __main__";
        body = "if __name__ == '__main__':\n\t$0";
      };
      lambda = {
        prefix = "lambda";
        description = "Lambda";
        body = "lambda \${1:vars} : \${2:action}";
      };
      lcp = {
        prefix = "lcp";
        description = "List comprehension";
        body = "[\${5:expression} for \${1:item} in \${2:items}\${3: if \${4:condition}}]";
      };
      lgen = {
        prefix = "lgen";
        description = "Generator Expression";
        body = "(\${5:expression} for \${1:item} in \${2:items}\${3: if \${4:condition}})";
      };
      scp = {
        prefix = "scp";
        description = "Set comprehension";
        body = "{\${5:expression} for \${1:item} in \${2:items}\${3: if \${4:condition}}}";
      };
      try = {
        prefix = "try";
        description = "Try / Except";
        body = "try:\n\t1\nexcept \${2:Exception} as \${3:e}:\n\t\${4:raise $3}";
      };
      trye = {
        prefix = "trye";
        description = "Try / Except / Else";
        body = "try:\n\t1\nexcept \${2:Exception} as \${3:e}:\n\t\${4:raise $3}\nelse:\n\t\${5:pass}";
      };
      tryef = {
        prefix = "tryef";
        description = "Try / Except / Else / Finally";
        body = "try:\n\t1\nexcept\${2: \${3:Exception} as \${4:e}}:\n\t\${5:raise}\nelse:\n\t\${6:pass}\nfinally:\n\t\${7:pass}";
      };
      tryf = {
        prefix = "tryf";
        description = "Try / Except / Finally";
        body = "try:\n\t1\nexcept \${2:Exception} as \${3:e}:\n\t\${4:raise $3}\nfinally:\n\t\${5:pass}";
      };
      while = {
        prefix = "while";
        description = "While loop statement";
        body = "while \${1:condition}:\n\t$2";
      };
      "with" = {
        prefix = "with";
        description = "With statement";
        body = "with \${1:expr} as \${2:var}:\n\t$3";
      };
    };
  };
}
