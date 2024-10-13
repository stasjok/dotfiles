{ lib, ... }:
{
  autoGroups.skeletons = { };
  autoCmd =
    let
      skeletons = [
        {
          pattern = "*/dotfiles/tests/nvim/*_test.lua";
          content = # lua
            ''
              local Child = require("test.Child")
              local expect = MiniTest.expect
              local new_set = MiniTest.new_set

              local eq = expect.equality
              local ok = expect.assertion

              local child = Child.new()

              local T = new_set({
                hooks = {
                  pre_case = child.setup,
                  post_once = child.stop,
                },
              })



              return T
            '';
          cursorLine = 17;
        }
      ];
    in
    map (skel: {
      desc = "New file skeleton";
      event = "BufNewFile";
      group = "skeletons";
      pattern = skel.pattern;
      callback = lib.nixvim.mkRaw ''
        function(args)
          vim.api.nvim_buf_set_lines(args.buf, 0, -1, true, ${
            lib.pipe skel.content [
              (lib.removeSuffix "\n")
              (lib.splitString "\n")
              lib.nixvim.toLuaObject
            ]
          })
          vim.api.nvim_win_set_cursor(0, {${toString skel.cursorLine or 1}, 0})
        end
      '';
    }) skeletons;
}
