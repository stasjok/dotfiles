{
  snippets.vscode = {
    language = "lua_spec";
    snippets = {
      describe = {
        prefix = "describe";
        description = "Context block";
        body = ''
          describe("''${1:block_title}", function()
          ''\t$0
          end)'';
      };
      it = {
        prefix = "it";
        description = "A test";
        body = ''
          it("''${1:test_title}", function()
          ''\t$0
          end)'';
      };
      pending = {
        prefix = "pending";
        description = "A placeholder for test";
        body = ''pending("''${1:test_title}")'';
      };
      before_each = {
        prefix = "before_each";
        description = "Run before each child test";
        body = [
          "before_each(function()"
          "\t$0"
          "end)"
        ];
      };
      after_each = {
        prefix = "after_each";
        description = "Run after each child test";
        body = [
          "after_each(function()"
          "\t$0"
          "end)"
        ];
      };
    };
  };
}
