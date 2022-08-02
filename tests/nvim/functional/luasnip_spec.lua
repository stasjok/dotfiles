local get_current_line = vim.api.nvim_get_current_line
local win_get_cursor = vim.api.nvim_win_get_cursor
local buf_set_lines = vim.api.nvim_buf_set_lines
local feedkeys = require("map").feedkeys

describe("LuaSnip", function()
  -- Load LuaSnip configuration
  local luasnip = require("luasnip")

  it("can load snippet", function()
    local s = luasnip.snippet
    local t = luasnip.text_node
    local i = luasnip.insert_node
    local c = luasnip.choice_node
    local number_of_snippets = #luasnip.available().all
    luasnip.add_snippets("all", {
      s("test_expand", {
        i(1, "pos1"),
        t(" "),
        c(2, { t("choice1"), t("choice2") }),
      }),
    })
    assert.are.equal(#luasnip.available().all, number_of_snippets + 1)
  end)

  describe("mapping", function()
    it("can expand snippet", function()
      feedkeys("itest_expand<C-H>", "tx")
      assert.are.equal("pos1 choice1", get_current_line())
    end)

    it("can jump", function()
      feedkeys("<C-J>", "tx")
      -- It exits insert mode, thats why it's 4, not 5
      assert.are.equal(4, win_get_cursor(0)[2])
    end)

    it("can change choice", function()
      feedkeys("<C-L>", "tx")
      assert.are.equal("pos1 choice2", get_current_line())
    end)

    it("can jump back", function()
      feedkeys("<C-K>", "tx")
      assert.are.equal(0, win_get_cursor(0)[2])
    end)

    describe("on_the_fly", function()
      before_each(function()
        feedkeys("<Esc>", "tx")
      end)

      after_each(function()
        luasnip.unlink_current()
        clear()
      end)

      it("can expand from selection", function()
        buf_set_lines(0, 0, -1, true, { "Hello, $username" })
        feedkeys("V<C-E>", "tx")
        assert.are.equal("Hello, username", get_current_line())
      end)

      it("can expand in insert mode", function()
        feedkeys('i<C-E>"', "tx")
        assert.are.equal("Hello, username", get_current_line())
      end)
    end)
  end)
end)
