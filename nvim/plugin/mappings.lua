local map = require("my.map").map
local map_expr = require("my.map").map_expr

-- Emacs-like mappings
map("!", "<C-B>", "<Left>")
map("!", "<C-F>", "<Right>")
map("!", "<M-b>", "<C-Left>")
map("!", "<M-f>", "<C-Right>")
map("i", "<C-N>", "<Down>")
map("i", "<C-P>", "<Up>")
map("c", "<C-A>", "<C-B>")
map("!", "<M-BS>", "<C-W>")
map("c", "<M-d>", "<C-F>dw<C-C>")

-- Shortcuts
map("n", "<leader><CR>", "<Cmd>buffer #<CR>")
map("n", "<leader>c", "<Cmd>close<CR>")
map("n", "<leader>C", "<Cmd>buffer #<CR><Cmd>bdelete #<CR>")
map("n", "<leader>w", "<Cmd>write<CR>")
map("n", "<leader>W", "<Cmd>wall<CR>")
map("n", "<leader>q", "<Cmd>quit<CR>")
map("n", "<leader>Q", "<Cmd>quitall<CR>")
map("n", "<leader>z", "<Cmd>xit<CR>")
map("n", "<leader>Z", "<Cmd>xall<CR>")

-- Create new lines in insert mode
map("i", "<M-n>", "<C-O>o")
map("i", "<M-p>", "<C-O>O")
-- Move lines
map("n", "<M-d>", "<Cmd>move .+1<CR>")
map("n", "<M-u>", "<Cmd>move .-2<CR>")
map("v", "<M-d>", ":move '>+1<CR>gv")
map("v", "<M-u>", ":move '<-2<CR>gv")

-- Window management
map("n", "<Leader>x", "<C-W>v")
map("n", "<Leader>v", "<C-W>s")
map("n", "<Leader>|", "<C-W>|")
map("n", "<Leader>_", "<C-W>_")
map("n", "<Leader>=", "<C-W>=")
map("n", "<Leader>H", "<C-W>H")
map("n", "<Leader>J", "<C-W>J")
map("n", "<Leader>K", "<C-W>K")
map("n", "<Leader>L", "<C-W>L")

-- Mouse mappings
-- automatic yanking after mouse selection
map("v", "<LeftRelease>", '<LeftRelease>"*y')
-- by default MiddleMouse yanks to unnamed buffer, but pastes from * (why?); change yanking also to *
map("v", "<MiddleMouse>", '"*y<MiddleMouse>')
-- by default MiddleMouse pastes at the position of the cursor in normal mode, but not in insert mode; fix it
map("i", "<MiddleMouse>", "<LeftMouse><MiddleMouse>")
-- increase mouse scroll speed
map({ "", "i", "t" }, "<ScrollWheelUp>", "<ScrollWheelUp><ScrollWheelUp>")
map({ "", "i", "t" }, "<ScrollWheelDown>", "<ScrollWheelDown><ScrollWheelDown>")

-- Make j/k movement a jump if count > 5
map_expr("n", "j", [[(v:count1 > 5 ? "m'"..v:count : '') .. 'j']])
map_expr("n", "k", [[(v:count1 > 5 ? "m'"..v:count : '') .. 'k']])

-- Clear search highlighting by pressing Enter
map_expr("n", "<CR>", "v:hlsearch ? '<Cmd>nohlsearch<CR>' : '<CR>'")
