local helpers = dofile("tests/nvim/helpers.lua")
local match = require("luassert.match")
local stub = require("luassert.stub")

describe("plugin/format", function()
  -- Stubs
  local revert_stubs = helpers.stubs({
    [vim.api] = {
      "nvim_buf_get_option",
      "nvim_create_augroup",
      "nvim_clear_autocmds",
      "nvim_create_autocmd",
    },
    [vim.keymap] = "set",
    [vim.lsp] = "get_client_by_id",
    [vim.lsp.buf] = "format",
  })
  local true_stub = stub.new(nil, nil, true)
  local false_stub = stub.new(nil, nil, false)
  local nil_stub = stub.new()
  after_each(function()
    true_stub:clear()
    false_stub:clear()
    nil_stub:clear()
  end)

  -- Load locals
  io.input("nvim/plugin/format.lua")
  local format_chunk = io.read("*a")
  format_chunk = format_chunk
    .. [[
return {
  settings = settings,
  format_with_client_id = format_with_client_id,
  configure_format = configure_format,
}]]
  local plugin = assert(loadstring(format_chunk, "Format plugin"))()

  describe("format_with_client_id", function()
    it("returns correct format function", function()
      local format_fun = plugin.format_with_client_id(10)
      format_fun()
      assert.stub(vim.lsp.buf.format).was_called_with({ id = 10 })
    end)
  end)

  describe("configure_format", function()
    local buf = 1
    local ft = "test"
    local client_id = 2
    local client_name = "test-ls"
    local client = {
      id = client_id,
      name = client_name,
      server_capabilities = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = true,
      },
    }
    local augroup = 3
    vim.api.nvim_buf_get_option.on_call_with(buf, "filetype").returns(ft)
    vim.lsp.get_client_by_id.on_call_with(client_id).returns(client)
    vim.api.nvim_create_augroup.returns(augroup)

    -- Matcher for on_save nvim_create_autocmd opts
    local function on_save_autocmd_opts()
      return function(value)
        if type(value) ~= "table" then
          return false
        end
        local count = 0
        for _, _ in pairs(value) do
          count = count + 1
        end
        return count == 4
          and value.desc == "Format on save"
          and value.group == augroup
          and value.buffer == buf
          and type(value.callback) == "function"
      end
    end
    assert:register("matcher", "on_save_autocmd_opts", on_save_autocmd_opts)

    ---@alias AssertConfigureFormatArgs { formatting_capability?: boolean, range_formatting_capability?: boolean, format_mapping?: boolean, range_format_mapping?: boolean, format_on_save?: boolean, extra_assert?: function }

    ---A helper for asserting `configure_format` function
    ---@param opts AssertConfigureFormatArgs
    local function assert_configure_format(opts)
      -- Server capabilities
      if opts.formatting_capability ~= nil then
        assert.are.equals(
          opts.formatting_capability,
          client.server_capabilities.documentFormattingProvider
        )
      end
      if opts.range_formatting_capability ~= nil then
        assert.are.equals(
          opts.range_formatting_capability,
          client.server_capabilities.documentRangeFormattingProvider
        )
      end

      -- Mappings
      local number_of_calles = 0
      if opts.format_mapping then
        assert
          .stub(vim.keymap.set)
          .was_called_with("n", "<Leader>F", match.is_function(), { buffer = buf })
        number_of_calles = number_of_calles + 1
      end
      if opts.range_format_mapping then
        assert
          .stub(vim.keymap.set)
          .was_called_with("x", "<Leader>F", match.is_function(), { buffer = buf })
        number_of_calles = number_of_calles + 1
      end
      assert.stub(vim.keymap.set).called(number_of_calles)

      -- Format on save
      if opts.format_on_save then
        assert.stub(vim.api.nvim_create_augroup).called(1)
        assert.stub(vim.api.nvim_create_augroup).was_called_with("FormatOnSave", { clear = false })
        assert.stub(vim.api.nvim_clear_autocmds).called(1)
        assert.stub(vim.api.nvim_clear_autocmds).was_called_with({ group = augroup, buffer = buf })
        assert.stub(vim.api.nvim_create_autocmd).called(1)
        assert
          .stub(vim.api.nvim_create_autocmd)
          .was_called_with("BufWritePre", match.on_save_autocmd_opts())
      else
        assert.stub(vim.api.nvim_create_augroup).was_not_called()
        assert.stub(vim.api.nvim_clear_autocmds).was_not_called()
        assert.stub(vim.api.nvim_create_autocmd).was_not_called()
      end

      if type(opts.extra_assert) == "function" then
        opts.extra_assert()
      end
    end

    ---@type { [string]: { documentFormattingProvider: boolean, documentRangeFormattingProvider: boolean, settings?: table, expect: AssertConfigureFormatArgs } }
    local tests = {
      ["works for unknown filetype"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = true,
        expect = {
          format_mapping = true,
          range_format_mapping = true,
          formatting_capability = true,
          range_formatting_capability = true,
        },
      },
      ["maps only for normal mode if range formatting is not supported"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = false,
        expect = {
          format_mapping = true,
          formatting_capability = true,
          range_formatting_capability = false,
        },
      },
      ["maps only for visual mode if only range formatting is supported"] = {
        documentFormattingProvider = false,
        documentRangeFormattingProvider = true,
        expect = {
          range_format_mapping = true,
          formatting_capability = false,
          range_formatting_capability = true,
        },
      },
      ["doesn't map anything if formatting is not supported"] = {
        documentFormattingProvider = false,
        documentRangeFormattingProvider = false,
        expect = { formatting_capability = false, range_formatting_capability = false },
      },
      ["skips language server if it's not matched"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = true,
        settings = { server = "not matched" },
        expect = { formatting_capability = true, range_formatting_capability = true },
      },
      ["sets up mapping for matching language server"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = false,
        settings = { server = client_name },
        expect = {
          format_mapping = true,
          formatting_capability = true,
          range_formatting_capability = false,
        },
      },
      ["overrides formatting capability for matching client"] = {
        documentFormattingProvider = false,
        documentRangeFormattingProvider = false,
        settings = { server = client_name, override_document_formatting = true },
        expect = {
          format_mapping = true,
          formatting_capability = true,
          range_formatting_capability = false,
        },
      },
      ["overrides range formatting capability for matching client"] = {
        documentFormattingProvider = false,
        documentRangeFormattingProvider = false,
        settings = { server = client_name, override_document_range_formatting = true },
        expect = {
          range_format_mapping = true,
          formatting_capability = false,
          range_formatting_capability = true,
        },
      },
      ["overrides both capabilities for matching client"] = {
        documentFormattingProvider = false,
        documentRangeFormattingProvider = false,
        settings = {
          server = client_name,
          override_document_formatting = true,
          override_document_range_formatting = true,
        },
        expect = {
          format_mapping = true,
          range_format_mapping = true,
          formatting_capability = true,
          range_formatting_capability = true,
        },
      },
      ["doesn't override capabilities for not matching clients"] = {
        documentFormattingProvider = false,
        documentRangeFormattingProvider = false,
        settings = {
          server = "not matched",
          override_document_formatting = true,
          override_document_range_formatting = true,
        },
        expect = { formatting_capability = false, range_formatting_capability = false },
      },
      ["overrides capabilities if language server isn't specified"] = {
        documentFormattingProvider = false,
        documentRangeFormattingProvider = false,
        settings = {
          override_document_formatting = true,
          override_document_range_formatting = true,
        },
        expect = {
          format_mapping = true,
          range_format_mapping = true,
          formatting_capability = true,
          range_formatting_capability = true,
        },
      },
      ["sets up format on save for matching client"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = false,
        settings = { server = client_name, on_save = true },
        expect = { format_mapping = true, format_on_save = true },
      },
      ["doesn't set up format on save for not matching client"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = false,
        settings = { server = "not matched", on_save = true },
        expect = { formatting_capability = true, range_formatting_capability = false },
      },
      ["doesn't set up format on save if formatting is not supported by client"] = {
        documentFormattingProvider = false,
        documentRangeFormattingProvider = true,
        settings = { server = client_name, on_save = true },
        expect = {
          range_format_mapping = true,
          formatting_capability = false,
          range_formatting_capability = true,
        },
      },
      ["sets up format on save if client_name isn't specified"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = false,
        settings = { on_save = true },
        expect = { format_mapping = true, format_on_save = true },
      },
      ["doesn't set up format on save if 'on_save = false'"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = false,
        settings = { on_save = false },
        expect = { format_mapping = true },
      },
      ["sets up format on save if 'on_save' is a function returning true"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = false,
        settings = { on_save = true_stub },
        expect = {
          format_mapping = true,
          format_on_save = true,
          extra_assert = function()
            assert.stub(true_stub).called(1)
            assert.stub(true_stub).was_called_with({ buf = buf, client = client })
            assert.stub(true_stub).returned_with(true)
          end,
        },
      },
      ["doesn't set up format on save if 'on_save' is a function returning false"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = false,
        settings = { on_save = false_stub },
        expect = {
          format_mapping = true,
          format_on_save = false,
          extra_assert = function()
            assert.stub(false_stub).called(1)
            assert.stub(false_stub).was_called_with({ buf = buf, client = client })
            assert.stub(false_stub).returned_with(false)
          end,
        },
      },
      ["doesn't set up format on save if 'on_save' is a function returning nil"] = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = false,
        settings = { on_save = nil_stub },
        expect = {
          format_mapping = true,
          format_on_save = false,
          extra_assert = function()
            assert.stub(nil_stub).called(1)
            assert.stub(nil_stub).was_called_with({ buf = buf, client = client })
          end,
        },
      },
    }

    -- Do tests in loop
    for name, opts in pairs(tests) do
      it(name, function()
        client.server_capabilities.documentFormattingProvider = opts.documentFormattingProvider
        client.server_capabilities.documentRangeFormattingProvider =
          opts.documentRangeFormattingProvider
        plugin.settings[ft] = opts.settings
        plugin.configure_format({ buf = buf, data = { client_id = client_id } })
        assert_configure_format(opts.expect)
      end)
    end
  end)

  -- Revert stubs
  revert_stubs()
end)
