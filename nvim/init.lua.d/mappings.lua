local map = vim.keymap.set

-- Leader shouldn't work by itself
map({ "n", "x" }, "<Leader>", "<Nop>")

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

-- Scrolling in insert mode (including completion popup)
map("i", "<M-F>", "<PageDown>")
map("i", "<M-B>", "<PageUp>")

-- Shortcuts
map("n", "<Leader><CR>", "<Cmd>buffer #<CR>")
map("n", "<Leader>e", "<Cmd>edit<CR>")
map("n", "<Leader>E", "<Cmd>edit!<CR>")
map("n", "<Leader>c", "<Cmd>close<CR>")
map("n", "<Leader>C", "<Cmd>buffer #<CR><Cmd>bdelete #<CR>")
map("n", "<Leader>w", "<Cmd>write<CR>")
map("n", "<Leader>W", "<Cmd>wall<CR>")
map("n", "<Leader>q", "<Cmd>quit<CR>")
map("n", "<Leader>Q", "<Cmd>quitall<CR>")
map("n", "<Leader>z", "<Cmd>xit<CR>")
map("n", "<Leader>Z", "<Cmd>xall<CR>")

-- Decrease indent
map("i", "<S-Tab>", "<C-D>")

-- Create new lines in insert mode
map("i", "<M-n>", "<C-O>o")
map("i", "<M-p>", "<C-O>O")
-- Append semicolon to the end of line
map("i", "<C-_>", "<End>;")

-- Move lines
map("n", "<M-d>", "<Cmd>move .+1<CR>")
map("n", "<M-u>", "<Cmd>move .-2<CR>")
map("v", "<M-d>", ":move '>+1<CR>gv", { silent = true })
map("v", "<M-u>", ":move '<-2<CR>gv", { silent = true })

-- Window management
map("n", "<Leader>x", "<C-W>v")
map("n", "<Leader>v", "<C-W>s")
map("n", "<Leader>|", "<C-W>|")
map("n", "<Leader>_", "<C-W>_")
map("n", "<Leader>=", "<C-W>=")

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
map("n", "j", [[(v:count1 > 5 ? "m'"..v:count : '') .. 'j']], { expr = true })
map("n", "k", [[(v:count1 > 5 ? "m'"..v:count : '') .. 'k']], { expr = true })

-- Clear search highlighting by pressing Esc
map("n", "<Esc>", "<Cmd>nohlsearch<CR>")

-- Jump to tag forward (inverse of Ctrl-t)
map("n", "<C-P>", "<Cmd>:tag<CR>")
