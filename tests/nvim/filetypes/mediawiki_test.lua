local Child = require("test.Child")
local helpers = require("test.helpers")
local expect = MiniTest.expect
local new_set = MiniTest.new_set
local finally = MiniTest.finally

local eq = expect.equality
local ok = expect.assertion

local child = Child.new()
local feed_keys = child.feed_keys
local get_lines = child.get_lines
local set_lines = child.set_lines
local cmd = child.cmd
local lua_get = child.lua_get
local fn = child.fn
local bo = child.bo
local wo = child.wo
local dedent = helpers.dedent

local T = new_set({ hooks = {
  pre_case = child.setup,
  post_once = child.stop,
} })

T["ftdetect"] = new_set({ parametrize = { { "test.mw" }, { "test.mediawiki" } } }, {
  test = function(filename)
    cmd.edit(filename)

    eq(bo.filetype, "mediawiki")
  end,
})

T["ftplugin"] = new_set({
  hooks = {
    pre_case = function()
      bo.filetype = "mediawiki"
    end,
  },
})

T["ftplugin"]["options"] = function()
  -- Infinite line length with line wrapping
  eq(wo.wrap, true)
  eq(wo.linebreak, true)
  eq(bo.textwidth, 0)
  eq(bo.wrapmargin, 0)
  for _, letter in ipairs({ "t", "c", "a" }) do
    ok(
      bo.formatoptions:find(letter) == nil,
      string.format("Expected no '%s' in formatoptions.", letter)
    )
  end
end

T["ftplugin"]["lists"] = new_set({ parametrize = {
  { "*" },
  { "#" },
  { ":" },
} }, {
  test = function(item)
    feed_keys("i", item, " ", "item 1", "<CR>", "item 2")
    eq(get_lines({ join = true }), string.format("%s item 1\n%s item 2", item, item))
  end,
})

T["syntax"] = new_set({
  hooks = {
    pre_case = function()
      cmd.edit("tests/fixtures/mediawiki/test.mw")
    end,
  },
})

local function get_hl_group(row, col)
  local syntax = lua_get("vim.inspect_pos(nil, ...).syntax", { row - 1, col - 1 })
  return syntax[#syntax].hl_group
end

T["syntax"]["fenced languages"] = function()
  -- Syntax highlighting
  eq(get_hl_group(9, 2), "htmlTagName")
  eq(get_hl_group(9, 18), "htmlArg")
  eq(get_hl_group(10, 1), "shStatement")
  eq(get_hl_group(10, 8), "shDoubleQuote")
  eq(get_hl_group(11, 4), "htmlTagName")

  -- Inline
  eq(get_hl_group(13, 18), "htmlTagName")
  eq(get_hl_group(13, 34), "htmlArg")
  -- Not supported
  -- eq(get_hl_group(13, 64), "shDoubleQuote")
  eq(get_hl_group(13, 70), "htmlTagName")
end

T["syntax"]["attrs"] = function()
  local function get_attr(row, col, what)
    local syn_id = fn.synID(row, col, 1)
    local syn_id_trans = fn.synIDtrans(syn_id)
    return fn.synIDattr(syn_id_trans, what)
  end

  eq(get_attr(3, 4, "italic"), "1")
  eq(get_attr(3, 16, "bold"), "1")
  eq(get_attr(3, 34, "italic"), "1")
  eq(get_attr(3, 34, "bold"), "1")
  eq(get_attr(5, 12, "italic"), "1")
  eq(get_attr(5, 32, "bold"), "1")
  eq(get_attr(5, 54, "underline"), "1")
end

T["fenced languages"] = new_set()

T["fenced languages"]["supported"] = new_set({
  parametrize = {
    { "sls", "key: 123", "yamlBlockMappingKey" },
  },
}, {
  test = function(lang, content, hl_group, col)
    -- Save test file contents to the temporary file
    local f = fn.tempname()
    finally(function()
      vim.fn.delete(f)
    end)
    fn.writefile({
      "<!-- vim: set ft=mediawiki: -->",
      string.format('<syntaxhighlight lang="%s">', lang),
      content,
      "</syntaxhighlight>",
    }, f)

    -- Edit file
    cmd.edit(f)

    eq(get_hl_group(3, col or 1), hl_group)
  end,
})

T["fenced languages"]["preloaded"] = new_set({
  parametrize = {
    { "bash", 'echo "test"', "shDoubleQuote", 8 },
  },
  hooks = {
    pre_case = function()
      bo.filetype = "mediawiki"
    end,
  },
}, {
  test = function(lang, content, hl_group, col)
    set_lines({
      string.format('<syntaxhighlight lang="%s">', lang),
      content,
      "</syntaxhighlight>",
    })

    eq(get_hl_group(2, col or 1), hl_group)
  end,
})

T["fenced languages"]["refreshed after buffer reloading"] = function()
  -- Temporary file
  local f = fn.tempname()
  finally(function()
    vim.fn.delete(f)
  end)

  -- Set initial buffer contents
  set_lines(dedent([[
    <!-- vim: set ft=mediawiki: -->
    == Heading ==

  ]]))
  cmd.write(f)
  cmd.edit()

  -- Add new syntaxhighlight region
  set_lines(
    dedent([[
      <syntaxhighlight lang="yaml">
      key: 123
      </syntaxhighlight>
    ]]),
    { start = -1 }
  )
  cmd.write()
  cmd.edit()

  -- Yaml block has syntax highlighting
  eq(get_hl_group(5, 2), "yamlBlockMappingKey")
end

return T
