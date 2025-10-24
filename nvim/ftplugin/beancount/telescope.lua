local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param node TSNode
---@return TSNode[]
local function get_subsections(node)
  local nodes = vim.iter(node:field("subsection")):map(get_subsections):flatten(1):totable()
  return vim.list_extend({ node }, nodes)
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
    :map(get_subsections)
    :totable()
  sections = vim.iter(sections):flatten(1):totable()

  ---@param entry TSNode
  ---@return table
  local function entry_maker(entry)
    local headline = entry:field("headline")[1]
    if not headline then
      return { valid = false }
    end
    local text = vim.treesitter.get_node_text(headline, bufnr)
    return {
      -- value = entry,
      display = text,
      ordinal = text:gsub("^[%s*]*", "", 1),
      path = vim.api.nvim_buf_get_name(bufnr),
      lnum = headline:start() + 1,
      lend = entry:end_(),
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
