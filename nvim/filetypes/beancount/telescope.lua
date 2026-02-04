local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param node TSNode Section node
---@param parents TSNode[] Section parents
---@return TSNode[][]
local function get_subsections(node, parents)
  local parents_with_node = vim.list_extend({}, parents)
  table.insert(parents_with_node, node)
  local subsections = vim
    .iter(node:field("subsection"))
    :map(function(node_)
      return get_subsections(node_, vim.list_extend({}, parents))
    end)
    :flatten(1)
    :map(function(node_)
      return vim.list_extend(vim.list_extend({}, parents_with_node), node_)
    end)
    :totable()
  table.insert(subsections, 1, parents_with_node)
  return subsections
end

local sections = function(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or 0

  if vim.bo[bufnr].filetype ~= "beancount" then
    vim.notify("This picker is only for beancount filetype", vim.log.levels.WARN)
    return
  end

  local parser = assert(vim.treesitter.get_parser(bufnr))
  local tree = parser:parse()[1]
  local sections = vim
    .iter(tree:root():iter_children())
    :filter(function(node)
      return node:type() == "section"
    end)
    :map(function(node)
      return get_subsections(node, {})
    end)
    :totable()
  sections = vim.iter(sections):flatten(1):totable()

  ---@param entry TSNode[]
  ---@return table
  local function entry_maker(entry)
    local headings = vim
      .iter(entry)
      :map(function(node)
        return node:field("headline")[1]
      end)
      :map(function(node)
        return node:field("item")[1]
      end)
      :map(function(node)
        return vim.treesitter.get_node_text(node, bufnr)
      end)
      :totable()
    return {
      value = entry,
      display = table.concat(headings, " -> "),
      ordinal = table.concat(headings, ""),
      path = vim.api.nvim_buf_get_name(bufnr),
      lnum = entry[#entry]:start() + 1,
      lend = entry[#entry]:end_(),
    }
  end

  pickers
    .new(opts, {
      prompt_title = "Beancount Sections",
      finder = finders.new_table({
        results = sections,
        entry_maker = entry_maker,
      }),
      sorter = conf.generic_sorter(opts),
      previewer = conf.grep_previewer(opts),
      attach_mappings = function(_, map)
        map({ "i", "n" }, "<C-J>", function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            selection.lnum = selection.lend
          end
          actions.select_default(prompt_bufnr)
        end, { desc = "select_end_default" })
        return true
      end,
    })
    :find()
end

return require("telescope").register_extension({
  exports = {
    sections = sections,
  },
})
